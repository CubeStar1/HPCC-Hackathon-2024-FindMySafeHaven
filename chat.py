import streamlit as st
import google.generativeai as genai
import PIL.Image
import glob
import tempfile
import os

BASE_PROMPT = "You will be provided with a persons data, you will need to provide a summary of the data in a concise and informative manner. Use bullet points and avoid repeating information."

def chat_page_fn(model, BASE_PROMPT):
    if "GOOGLE_API_KEY" not in st.session_state:
        st.session_state.GOOGLE_API_KEY = ""
    if "message_count" not in st.session_state:
        st.session_state.message_count = 0

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

    for message in st.session_state.messages:
        if message["role"] == "user":
            if message["parts"] != BASE_PROMPT:
                with st.chat_message(message["role"]):
                    st.markdown(message["parts"])
        if message["role"] == "model":
            with st.chat_message("assistant"):
                st.markdown(message["parts"])

    if st.session_state.message_count == 0 and st.session_state.GOOGLE_API_KEY != "":
        model_vision = genai.GenerativeModel('gemini-pro')
        message_vision = [BASE_PROMPT]
        response_vision = model_vision.generate_content(message_vision, safety_settings={'HATE_SPEECH':'block_none'})
        with st.chat_message("assistant"):
            st.markdown(response_vision.text)

        st.session_state.messages.append({"role": "user", "parts": BASE_PROMPT})
        st.session_state.messages.append({"role": "model", "parts": response_vision.text})
        st.session_state.message_count += 1

    # Accept user input
    if st.session_state.GOOGLE_API_KEY != "":
        prompt = st.text_input("")
        if prompt:

            prompt_engineered = "answer it in a sarcastic tone, short and include all equations"
            st.session_state.messages.append({"role": "user", "parts": prompt})
            with st.chat_message("user"):
                st.markdown(prompt)

            with st.chat_message("assistant"):
                messages = [{"role": m["role"], "parts": [m["parts"]]} for m in st.session_state.messages]

                response = model.generate_content(messages, stream=st.session_state.stream, safety_settings={'HATE_SPEECH':'block_none','HARASSMENT':'block_none'})

                if st.session_state.stream:
                    for chunk in response:
                        st.write(chunk.text)
                else:
                    st.write(response.text)
            st.session_state.messages.append({"role": "model", "parts": response.text})

        if st.toggle("Toggle Stream"):
            st.session_state.stream = not st.session_state.stream

