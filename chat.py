import streamlit as st
import google.generativeai as genai
import PIL.Image
import glob

import tempfile
import os


#model = genai.GenerativeModel('gemini-pro-vision')

#BASE_PROMPT_VISION = "What is this compound and what are some of its properties? Answer it as short as possible and include all equations."
BASE_PROMPT = "You will be provided with a persons data, you will need to provide a summary of the data in a concise and informative manner. Use bullet points and avoid repeating information."


# def text_to_speech(text, lang='en', slow=False):
#     tts = gTTS(text=text, lang=lang, slow=slow)
#     return tts
def chat_page_fn(model, BASE_PROMPT):
    if "GOOGLE_API_KEY" not in st.session_state:
        st.session_state.GOOGLE_API_KEY = ""
    if "message_count" not in st.session_state:
        st.session_state.message_count = 0
    # st.title("Chat with Gemini")
    # with st.expander("Last Question", expanded=True):
    #     if st.session_state.prediction_df != []:
    #         st.markdown(f'<div id="" style="overflow:scroll; height:300px; padding-left: 20px; ">{st.session_state.prediction_df[-1]}</div>',
    #                                unsafe_allow_html=True)
    #st.markdown('# Chat with Gemini')
    #st.markdown('---')

    # Set a default model
    if "genai_model" not in st.session_state:
        st.session_state["genai_model"] = "gemini-pro"

    # Set a default API key
    if st.session_state["GOOGLE_API_KEY"] == "":
        with st.expander("Set Google API Key"):
            GOOGLE_API_KEY = st.text_input("Enter your Google API Key")
        st.session_state["GOOGLE_API_KEY"] = GOOGLE_API_KEY
        genai.configure(api_key=GOOGLE_API_KEY)


    # Initialize chat history
    if "messages" not in st.session_state:
        st.session_state.messages = []

    if "stream" not in st.session_state:
        st.session_state.stream = False


    # with st.container(border=True, height=500):
    # Display chat messages from history on app rerun
    for message in st.session_state.messages:
        if message["role"] == "user":
            if message["parts"] != BASE_PROMPT:
                with st.chat_message(message["role"]):
                    st.markdown(message["parts"])
        if message["role"] == "model":
            with st.chat_message("assistant"):
                st.markdown(message["parts"])

    if st.session_state.message_count == 0 and st.session_state.GOOGLE_API_KEY != "":
        #img_path = glob.glob('./images/*.png')[0]
        #print(img_path)
        #img = PIL.Image.open(img_path)
        #img = PIL.Image.open('C:\\Users\\avina\\PycharmProjects\\ChemPredictorv2\\images\\0C1=CC=CC=C1.png')
        model_vision = genai.GenerativeModel('gemini-pro')
        message_vision = [BASE_PROMPT]
        response_vision = model_vision.generate_content(message_vision, safety_settings={'HATE_SPEECH':'block_none'})
        with st.chat_message("assistant"):
            st.markdown(response_vision.text)
            # tts = text_to_speech(response_vision.text, lang='en', slow=False)
            # with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as fp:
            #     tts.save(fp.name)
            #     st.audio(fp.name, format="audio/mp3")

        st.session_state.messages.append({"role": "user", "parts": BASE_PROMPT})
        st.session_state.messages.append({"role": "model", "parts": response_vision.text})
        #st.markdown(st.session_state.messages)
        #st.markdown(message_count)
        st.session_state.message_count += 1


    # Accept user input
    if st.session_state.GOOGLE_API_KEY != "":
        prompt = st.text_input("")
        if prompt:

            # Add user message to chat history
            prompt_engineered = "answer it in a sarcastic tone, short and include all equations"
            #st.session_state.messages.append({"role": "user", "parts": prompt_engineered})
            st.session_state.messages.append({"role": "user", "parts": prompt})
            # Display user message in chat message container
            with st.chat_message("user"):
                st.markdown(prompt)

            with st.chat_message("assistant"):
                #img = PIL.Image.open('C:\\Users\\avina\\PycharmProjects\\ChemPredictorv2\\images\\0C1=CC=CC=C1.png')
                messages = [{"role": m["role"], "parts": [m["parts"]]} for m in st.session_state.messages]
                # with st.spinner("Thinking..."):
                #model.generate_content()

                response = model.generate_content(messages, stream=st.session_state.stream, safety_settings={'HATE_SPEECH':'block_none','HARASSMENT':'block_none'})
                #st.write(response)
                #st.write(response.text)

                if st.session_state.stream:
                    for chunk in response:
                        st.write(chunk.text)
                else:
                    st.write(response.text)
            st.session_state.messages.append({"role": "model", "parts": response.text})


        if st.toggle("Toggle Stream"):
            st.session_state.stream = not st.session_state.stream

        # col1, col2 = st.columns([1, 3])
        # with col1:
        #
        #     tts_button = st.button("Listen to the response", use_container_width=True)
        #
        # if tts_button:
        #     print(st.session_state.messages[-1]['parts'])
        #     tts = text_to_speech(st.session_state.messages[-1]['parts'], lang='en', slow=False)
        #     with tempfile.NamedTemporaryFile(delete=False, suffix=".mp3") as fp:
        #         tts.save(fp.name)
        #         with col2:
        #             st.audio(fp.name, format="audio/mp3")

# model = genai.GenerativeModel('gemini-pro')
# chat_page_fn(model, BASE_PROMPT)