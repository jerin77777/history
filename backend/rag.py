import os
from langchain_openai import AzureChatOpenAI

from langchain_openai import AzureOpenAIEmbeddings
from langchain_community.document_loaders import PyPDFLoader
from langchain_community.vectorstores import FAISS
from langchain.prompts import PromptTemplate

from langchain.chains import RetrievalQA


def getRag(query):
    llm = AzureChatOpenAI(
        azure_endpoint="https://tuesday-engine.openai.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-08-01-preview",
        api_key=os.environ["AZURE_OPENAI_KEY"],
        api_version="2024-08-01-preview"
    )

    embeddings = AzureOpenAIEmbeddings(
        azure_endpoint="https://tuesday-engine.openai.azure.com/openai/deployments/text-embedding-3-large/embeddings?api-version=2023-05-15",
        api_key=os.environ["AZURE_OPENAI_KEY"],
        model="text-embedding-3-large",
    )


    loader = PyPDFLoader(f"./data/data.pdf")
    texts = loader.load_and_split()

    doc_search = FAISS.from_documents(texts, embeddings)


    prompt_template = """
    Answer the question as detailed as possible from the provided context, make sure to provide all the details,
    Context:\n {context}?\n
    Question: \n{question}\n

    Answer:
    """

    prompt = PromptTemplate(
        template=prompt_template, input_variables=["context", "question"]
    )

    chain = RetrievalQA.from_chain_type(
        llm=llm, 
        chain_type="stuff", 
        retriever=doc_search.as_retriever(
            search_type="similarity", search_kwargs={"k" : 6 }
        ),
        verbose=False,
        return_source_documents=True,
        chain_type_kwargs={"prompt": prompt},
    )



    response = chain.invoke({"query": query})

    return response["result"]


