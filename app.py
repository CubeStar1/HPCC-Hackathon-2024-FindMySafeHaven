import streamlit as st
import google.generativeai as genai
from utils import get_person_data, convert_to_df
from chat import chat_page_fn
st.title("Search the Persons Dataset")


fname = st.text_input("Enter the first name of the person you want to search for")
lname = st.text_input("Enter the last name of the person you want to search for")
gender = st.selectbox("Select Gender", ["M", "F"])
state = st.selectbox("Select State", ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"])

fname = fname.upper()
lname = lname.upper()
gender = gender.upper()
state = state.upper()

if "json_string" not in st.session_state:
    st.session_state.json_string = ""
if st.button("Search"):
    json_file = get_person_data(fname, lname, gender, state)
    json_string = json_file["bobf.peoplefilesearchservice.1Response"]["Results"]["result_1"]["Row"][0]
    st.session_state.json_string = json_string

if st.session_state.json_string != "":
    df = convert_to_df(st.session_state.json_string)
    st.dataframe(df)
BASE_PROMPT = "You will be provided with a persons data, you will need to provide a summary of the data in a concise and informative manner. Use bullet points and avoid repeating information. Here is the data you need to summarize: " + str(st.session_state.json_string)
model = genai.GenerativeModel('gemini-pro')
chat_page_fn(model, BASE_PROMPT)
