from google.cloud import firestore
import pandas as pd
import numpy as np
import json


def get_recommendation(request):
    
    request_json = request.get_json()
    try:
        favorites = request_json["favorites"]
    except Exception:
        favorites = []
    try:
        history = request_json["history"]
    except Exception:
        history = []

    try:
        cosine_sim, ids, indices, data_length = get_matrix_data()
        num_scores = int(0.3 * data_length)
        #min_fav =  5
        #fav = merge_fav_history(favorites, history, min_fav)
        if len(favorites) == 0 and len(history) != 0:
            favorites = history
        elif len(favorites) == 0 and len(history) == 0:
            return {"recommendation": []}
        rec = get_recommendation_list(favorites, indices, ids, cosine_sim, num_scores, data_length)
        return {"recommendation": rec}
    except Exception:
        return {"recommendation": []}


def get_matrix_data():
    db = firestore.Client(project='take-a-pet')
    doc = db.collection(u'matrix').document(u'matrix_data').get()
    if doc.exists:
        dic = doc.to_dict()
        data_length = int(dic['data_length'])
        cosine_sim = np.array(json.loads(dic['cosine_sim']))
        ids = pd.read_json(dic['ids'], typ='series', orient='records')
        indices = pd.read_json(dic['indices'], typ='series', orient='records')
        return cosine_sim, ids, indices, data_length
    else:
        raise Exception('No such document!')


def merge_fav_history(favorites, history, min_fav):
    if len(favorites) >= min_fav:
        return favorites
    else:
        to_add = min_fav - len(favorites)
        for i in range(to_add):
            try:
                favorites.append(history[len(history) - 1 - i])
            except Exception:
                pass


def from_id_to_index(ids_list, indices):
    index_list = []
    for i in ids_list:
        try:
            index_list.append(int(indices[i]))
        except Exeptiont:
            pass
    return index_list


def get_recommendation_list(fav, indices, ids, cosine_sim, num_scores, data_length):
    fav_index = from_id_to_index(fav, indices)
    fav_len = len(fav_index)
    if fav_len != 0:
        scores_list = []
        for i in range(data_length):
            score = 0
            # if the current profile is not in fav
            if i not in fav_index:
                for j in range(data_length):
                    # calculate mean score only with profile in fav
                    if j in fav_index:
                        score += cosine_sim[i, j]
                scores_list.append((i, score / fav_len))

        scores_list = sorted(scores_list, key=lambda x: x[1], reverse=True)
        scores_list = scores_list[0:num_scores]
        profile_indices = [i[0] for i in scores_list]
        # Return the top most similar profiles id
        return ids.iloc[profile_indices].tolist()
    else:
        return []