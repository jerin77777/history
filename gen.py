from openai import OpenAI
import os 


def samba(model, query):

    client = OpenAI(
        api_key=os.environ.get('SAMBA_KEY'),
        base_url="https://api.sambanova.ai/v1",
    )

    response = client.chat.completions.create(
        # model='Meta-Llama-3.1-70B-Instruct',
        model=model,
        messages=[{"role": "system", "content": "You are a helpful assistant"}, {"role": "user", "content": query}],
        temperature =  0.1,
        top_p = 0.1
    )

    return response.choices[0].message.content

