# import json
# import os
from langchain_community.document_loaders import DirectoryLoader, TextLoader, UnstructuredFileLoader
from langchain.indexes import VectorstoreIndexCreator
from langchain.embeddings.openai import OpenAIEmbeddings

from functions.speech import *
from functions.utils import *
from video_gen import *
from langchain_community.vectorstores import FAISS
from langchain_community.llms import OpenAI
from langchain.chains import RetrievalQA

from langchain.text_splitter import CharacterTextSplitter
# import nltk
# nltk.download("punkt")
def get_history(socketId,file,question):

    loader = UnstructuredFileLoader(f".{file}")
    documents = loader.load()

    text_splitter = CharacterTextSplitter(chunk_size=1500, chunk_overlap=0)
    texts = text_splitter.split_documents(documents)
    print(texts)

    embeddings = OpenAIEmbeddings(openai_api_key=os.environ["OPENAI_API_KEY"])
    doc_search = FAISS.from_documents(texts, embeddings)
    retriever = doc_search.as_retriever()



    chain = RetrievalQA.from_llm(llm=OpenAI(), retriever=retriever)
    print("loaded")
    ans = chain.run(question)
    print(ans)

    send(socketId,"progress", 10)


    ans += " create an easy to understand teaching script for this text. state only the body without introduction and conclusion"
    narration = gen(ans)
    print(narration)

    send(socketId,"progress",15)

    #
    queries = None
    while queries is None:
        ans = narration + ' sepreate the text that has a different key idea and create a array of json using the format {"key_idea":value,"text":value} make sure concatenating text values does not differ from the original text, return the array only'
        ans = gen(ans)

        try:
            queries = json.loads(ans)
            print(queries)
        except:
            print("caught")
            queries = None

    send(socketId,"progress",20)

    queries = None
    while queries is None:
        temp = "rules: No NSFW or obscene content. This includes, nudity, sexual acts, explicit violence, or graphically disturbing material.\n\n"
        temp = temp + ans + ' for each item in array create a 4 second video scene description that follow above rules for the "text" with add it in the json with key "video_description"'
        temp = gen(temp)

        try:
            queries = json.loads(temp)
        except:
            print("caught")
            queries = None

    send(socketId,"progress",30)


    print(queries)
    print(len(queries))

    scrollDown()



    for query in queries:
        query["promptId"] = prompt(query["video_description"])
        print(query["promptId"])

    send(socketId,"progress",40)


    for query in queries:
        speech = speak(query["text"].strip())
        query["word_timings"] = speech["word_timings"]
        query["word_visemes"] = speech["word_visemes"]
        query["file"] = speech["file"]

    send(socketId,"progress",90)

    toggle()

    for query in queries:
        src = get_src(query["promptId"])
        query["image"] = src["img"]
        query["video"] = src["vid"]

    toggle()


    # print(queries)
    return queries



