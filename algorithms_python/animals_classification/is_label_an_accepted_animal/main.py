import nltk
from nltk.corpus import wordnet as wn
import os
from flask import Flask, abort


# global variable
acceptedAnimals = ['cat', 'chicken', 'dog', 'frog', 'toad','lizard', 'horse', 'rabbit', 'hare', 'Angora', 'snake', 'squirrel']

ANIMAL_PHOTO = False

def check_label(request):

    if request.method == 'POST':
        try:
            print('run model')
            label_to_check = request.form["label"]
            model_result = check_if_accepted(label_to_check)
            return model_result
        except Exception as e:
            return {'outResult': 'Error', 'message': str(e)}
    else:
        return {'outResult': 'Error', 'message': 'Send a valid request'}


def downloading_wordnet():
    print('downloading wordnet')
    nltk.download('wordnet', 'WORDNET_saved')
    print('done downloading wordnet')


def find_upperclasses(obj, lstr):
    for s in obj.hypernyms():
        for w in s.lemma_names():
            lstr.append(w)
            if (w == 'animal' or w == 'entity'):
                return lstr
        find_upperclasses(s, lstr)
    return lstr


def is_accepted_animal(obj, l):
    is_animal = False
    accepted_type = False
    global ANIMAL_PHOTO

    hyponyms = find_upperclasses(obj, l)

    animal_type = ''
    if ('animal' in hyponyms):
        ANIMAL_PHOTO = True
        is_animal = True
        for animal in acceptedAnimals:
            if animal in hyponyms:
                accepted_type = True
                animal_type = animal
                break
    return ((is_animal and accepted_type), animal_type)



def check_if_accepted(pred_label):
    global ANIMAL_PHOTO
    ANIMAL_PHOTO = False

    # the location of the saved wordnet
    # nltk.data.path.append("WORDNET_saved/")

    # if not os.path.isdir('WORDNET_saved/corpora'):
    # downloading_wordnet()
    nltk.download('wordnet')

    try:
        synsets = wn.synsets(pred_label)
        if (synsets == []):
            return {'outResult': False, 'message': 'not existing word in English'}
        for sy in synsets:
            l = list()
            l.append(pred_label)
            # for every synonymous word
            obj = wn.synset(sy.name())
            # see the meaning of the word
            # print('DEF', sy.definition())
            # 'animal' in upperClasses
            checkResult = is_accepted_animal(obj, l)
            if checkResult[0]:
                return {'outResult': True, 'message':  checkResult[1]}
        # this photo is an animal, but not accepted
        if ANIMAL_PHOTO:
            return {'outResult': False, 'message': 'This Animal type is not accepted in this app because its is not a typical pet'}
        return {'outResult': False, 'message': 'This is not an Animal'}
    except Exception as e:
        raise Exception('Error occurred while classifying your image, please try again')
