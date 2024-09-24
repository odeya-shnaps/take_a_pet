# classification Func Cloud
from flask import Flask, abort

from tensorflow.keras.preprocessing.image import load_img
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras.applications.vgg16 import preprocess_input
from tensorflow.keras.applications.vgg16 import decode_predictions
from tensorflow.keras.applications.vgg16 import VGG16
from tensorflow.keras.preprocessing.image import smart_resize

import numpy as np

from PIL import Image
import io
import base64



def classify_image(request):

    if request.method == 'POST':
        try:
            print('run model')
            image_to_classify = request.form["image"]
            model_result = run_model(image_to_classify)
            return model_result
        except Exception as e:
            print('Error')
            return {'isMultiple': 'Error', 'label': str(e)}
    else:
        return {'isMultiple': 'Error', 'label': 'Send a valid request'}


def loading_animal_classification_model():
    print('loading_animal_classification_model')
    try:
        global model
        model = VGG16(weights='imagenet')
    except Exception as e:
        print(e)
        raise e




def prepare_image_for_model(image_url):
    print('prepare_image_for_model')
    img_bytes = base64.b64decode(image_url.encode('utf-8'))
    # convert to PIL
    img = Image.open(io.BytesIO(img_bytes))
    sized_img = smart_resize(img, size=(224, 224))
    # convert the image pixels to a numpy array
    image = np.array(sized_img)  
    # reshape data for the model
    image = image.reshape((1, image.shape[0], image.shape[1], image.shape[2]))
    # setting the writeable flag to the image array
    image.setflags(write=1)
    # prepare the image for the VGG model
    image = preprocess_input(image)
    return image


def create_list_of_possible_labels(possiblePredictions):
    l = list()
    for option in possiblePredictions:
        l.append(option[1])
    return l


def run_model(image_url):
    print('run model')
    try:
        loading_animal_classification_model()
        image = prepare_image_for_model(image_url)

        # predict the probability across all output classes
        yhat = model.predict(image)
        # convert the probabilities to class labels
        predictions = decode_predictions(yhat)

        # retrieve the most likely result, e.g. highest probability
        label = predictions[0][0]
        percentage = label[2] * 100
        print('highest percentage: %s (%.2f%%)' % (label[1], percentage))

        # the model has low percentage to be right
        if percentage < 75.0:
            print('the picture is not clear enough')
            # returning the labels to the user so he will be able to choose
            return {'isMultiple': True, 'label': create_list_of_possible_labels(predictions[0])}

        return {'isMultiple': False, 'label': label[1]}
    except Exception as e:
        print('exception')
        raise Exception('Error occurred while classifying your image, please try again')

