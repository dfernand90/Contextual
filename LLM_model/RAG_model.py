from llama_index.core import Settings, VectorStoreIndex, SimpleDirectoryReader
from llama_index.embeddings.huggingface import HuggingFaceEmbedding
from llama_index.llms.ollama import Ollama
from transformers import AutoTokenizer
#from IPython.display import Markdown, display

def create_a_query_engine(model ="llama3.2:1b", temperature = 0.75, document_path = "C:\\django_test\\userfolder\\er"):
    # set the LLM
    
    llm = Ollama(model=model,temperature=temperature, request_timeout=360.0)
    Settings.llm = llm

    Settings.embed_model = HuggingFaceEmbedding(
        model_name="BAAI/bge-small-en-v1.5"
    )

    documents = SimpleDirectoryReader(document_path).load_data()

    index = VectorStoreIndex.from_documents(
        documents,
    )

    query_engine = index.as_query_engine()
    return query_engine

def model_response(query_engine, query = "hello, tell me how interesting this app is!" ):
    response = query_engine.query(query)
    return str(response)
if __name__ == "__main__":
    query_engine = create_a_query_engine()
    response = query_engine.query("What is Concrete cover for submerged panels?")
    print(response)