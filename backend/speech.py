import azure.cognitiveservices.speech as speechsdk
import requests, uuid

def translate(lang,text):

    # Add your key and endpoint
    key = "43KRHJjHtaXM4IlBdLHcePSnwsLORsBPuwyRSIsiRxVLZ0pj411aJQQJ99BCACYeBjFXJ3w3AAAbACOGGGD4"
    endpoint = "https://api.cognitive.microsofttranslator.com"

    # location, also known as region.
    # required if you're using a multi-service or regional (not global) resource. It can be found in the Azure portal on the Keys and Endpoint page.
    location = "eastus"

    path = '/translate'
    constructed_url = endpoint + path

    params = {
        'api-version': '3.0',
        'from': 'en',
        'to': [lang]
    }

    headers = {
        'Ocp-Apim-Subscription-Key': key,
        'Ocp-Apim-Subscription-Region': location,
        'Content-type': 'application/json',
        'X-ClientTraceId': str(uuid.uuid4())
    }

    # You can pass more than one object in body.
    body = [{
        'text': text
    }]

    request = requests.post(constructed_url, params=params, headers=headers, json=body)
    response = request.json()
    

    print(response[0]["translations"][0]["text"])
    return response[0]["translations"][0]["text"] 

def speak(text, language):

    speech_key = "7U9EHOPrkB302J9N0HNN94HGc1SpROCIajP3VU7M7vMc3JvvNI7NJQQJ99BCACYeBjFXJ3w3AAAYACOGx23h"
    service_region = "eastus"

    speech_config = speechsdk.SpeechConfig(subscription=speech_key, region=service_region)
    # Note: the voice setting will not overwrite the voice element in input SSML.
    if language == "Tamil":
        text = translate("ta",text)
        speech_config.speech_synthesis_voice_name = "ta-IN-PallaviNeural"
    elif language == "Hindi":
        text = translate("hi",text)
        speech_config.speech_synthesis_voice_name = "hi-IN-AaravNeural"
    elif language == "French":
        text = translate("fr",text)
        speech_config.speech_synthesis_voice_name = "fr-BE-CharlineNeural"
    elif language == "Mandrin":
        text = translate("zh-CN",text)
        speech_config.speech_synthesis_voice_name = "yue-CN-XiaoMinNeural"
    else:
        speech_config.speech_synthesis_voice_name = "en-US-TonyNeural"


    audio_config = speechsdk.audio.AudioOutputConfig(use_default_speaker=True,filename=f"./speech/audio.wav")
    # use the default speaker as audio output.
    speech_synthesizer = speechsdk.SpeechSynthesizer(speech_config=speech_config, audio_config=audio_config)

    result = speech_synthesizer.speak_text_async(text).get()
    # Check result
    if result.reason == speechsdk.ResultReason.SynthesizingAudioCompleted:
        print("Speech synthesized for text [{}]".format(text))
    elif result.reason == speechsdk.ResultReason.Canceled:
        cancellation_details = result.cancellation_details
        print("Speech synthesis canceled: {}".format(cancellation_details.reason))
        if cancellation_details.reason == speechsdk.CancellationReason.Error:
            print("Error details: {}".format(cancellation_details.error_details))

    return {"text": text}

