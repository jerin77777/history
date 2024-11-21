from llama_index.core import Settings
from llama_index.llms.nvidia import NVIDIA
from llama_index.embeddings.nvidia import NVIDIAEmbedding
from llama_index.core.node_parser import SentenceSplitter
from llama_index.core import SimpleDirectoryReader
from llama_index.postprocessor.nvidia_rerank import NVIDIARerank
from llama_index.core import VectorStoreIndex


def getRag(query):

    Settings.llm = NVIDIA(model="mistralai/mixtral-8x7b-instruct-v0.1")

    Settings.embed_model = NVIDIAEmbedding(model="NV-Embed-QA", truncate="END")


    Settings.text_splitter = SentenceSplitter(chunk_size=400)
    documents = SimpleDirectoryReader("./data/").load_data()

    index = VectorStoreIndex.from_documents(documents)

    reranker_query_engine = index.as_query_engine(
        similarity_top_k=40, node_postprocessors=[NVIDIARerank(top_n=4)]
    )

    response = reranker_query_engine.query(
        query
    )

    return response




