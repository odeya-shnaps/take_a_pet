from google.cloud import firestore
import pandas as pd
from ast import literal_eval
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import json
import logging

logging.basicConfig(level=logging.INFO)
db = firestore.Client(project='take-a-pet')

def get_collection():
    
    docs = db.collection(u'animals').stream()
    animals_dic = {}
    indx = 0

    for doc in docs:
        animal_id = doc.id
        dic = doc.to_dict()

        # breed, gender, isTrained pre-processing
        list_breed = dic['breed'].split(' ')
        breed = ""
        for b in list_breed:
            breed = breed + b + ','
        breed = breed[0:-1]

        if dic['gender'] == 'Female':
            gender = 'f'
        else:
            gender = 'm'

        if dic['isTrained'] is None:
            is_trained = ''
        elif dic['isTrained']:
            is_trained = 'y'
        else:
            is_trained = 'n'

        dic_list = [animal_id, dic['name'], dic['type'], dic['age'], gender, dic['size'], dic['likes'], is_trained,
                    breed, dic['color'], dic['qualities'], dic['about']]

        animals_dic[indx] = dic_list
        indx += 1

    # convert animals dictionary to dataframe
    animal_profiles = pd.DataFrame.from_dict(animals_dic, orient='index',
                                             columns=['id', 'name', 'type', 'age', 'gender', 'size', 'likes',
                                                      'is_trained', 'breed', 'colors', 'qualities', 'about'])
    return animal_profiles


def perfect_eval(non_string):
    non_string = str(non_string)
    try:
        ev = literal_eval(non_string)
        return ev
    except Exception:
        corrected = "\'" + non_string + "\'"
        ev = literal_eval(corrected)
        return ev


def clean_data(x):
    if isinstance(x, list):
        return [str.lower(i.replace(" ", "")) for i in x]
    else:
        # Check if director exists. If not, return empty string
        if isinstance(x, str):
            return str.lower(x.replace(" ", ""))
        else:
            return ''


def get_list(x):
    if x != 'nan':
        x = x.split(',')
        return x
    return []


def create_soup(x):
    return ' '.join(x['type']) + ' ' + ' '.join(x['breed']) + ' ' + x['age'] + ' ' + ' '.join(x['gender']) + ' ' \
           + ' '.join(x['size']) + ' ' + ' '.join(x['is_trained']) + ' ' + ' '.join(x['qualities']) + ' ' + ' '.join(x['colors'])


def pre_processing():

    animal_profiles = get_collection()

    features = ['type', 'breed', 'age', 'gender', 'is_trained', 'size', 'qualities', 'colors']
    for feature in features:
        animal_profiles[feature] = animal_profiles[feature].apply(perfect_eval)

    # converting breed to list of words.
    animal_profiles['breed'] = animal_profiles['breed'].apply(get_list)

    animal_profiles['age'] = animal_profiles['age'].astype('str').apply(lambda x: str.lower(x.replace(" ", "")))
    animal_profiles['type'] = animal_profiles['type'].astype('str').apply(lambda x: str.lower(x.replace(" ", "")))
    animal_profiles['type'] = animal_profiles['type'].apply(lambda x: [x, x, x])

    features = ['breed', 'gender', 'is_trained', 'size', 'qualities', 'colors']
    for feature in features:
        animal_profiles[feature] = animal_profiles[feature].apply(clean_data)

    animal_profiles['breed'] = animal_profiles['breed'] + animal_profiles['breed']

    # stemmer = SnowballStemmer('english') add to qualities??

    animal_profiles['soup'] = animal_profiles.apply(create_soup, axis=1)
    return animal_profiles


def update_data(request):

    animal_profiles = pre_processing()

    data_length = animal_profiles.shape[0]
    num_scores = int(0.2 * data_length)

    count = CountVectorizer(analyzer='word', ngram_range=(1, 2), min_df=0, stop_words='english')
    count_matrix = count.fit_transform(animal_profiles['soup'])

    cosine_sim = cosine_similarity(count_matrix, count_matrix)
    json_matrix = json.dumps(cosine_sim.tolist())

    animal_profiles = animal_profiles.reset_index()
    ids = animal_profiles['id']

    indices = pd.Series(animal_profiles.index, index=animal_profiles['id'])
    matrix_data = {'cosine_sim': json_matrix, 'indices':indices.to_json(), 'ids':ids.to_json(), 'data_length': data_length, 'num_scores': num_scores}
    update_document(matrix_data)

def update_document(json_doc):
    # If the document does not exist, it will be created. If the document does exist, its contents will be overwritten with the newly provided data
    db.collection(u'matrix').document(u'matrix_data').set(json_doc)

