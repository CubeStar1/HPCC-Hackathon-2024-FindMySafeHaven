import streamlit as st
import google.generativeai as genai
from utils import *
from chat import chat_page_fn
import pandas as pd
from streamlit_geolocation import streamlit_geolocation
from geopy.geocoders import Nominatim
import folium
import os

st.set_page_config(page_title="Find My Safe Haven", layout='wide', page_icon=":bar_chart:")

if "church_json" not in st.session_state:
    st.session_state.church_json = ""
if "food_json" not in st.session_state:
    st.session_state.food_json = ""
if "fire_json" not in st.session_state:
    st.session_state.fire_json = ""
if "hospital_json" not in st.session_state:
    st.session_state.hospital_json = ""
if "police_json" not in st.session_state:
    st.session_state.police_json = ""
if "core_json" not in st.session_state:
    st.session_state.core_json = ""
if "json_list" not in st.session_state:
    st.session_state.json_list = []

if "location" not in st.session_state:
    st.session_state.location = {"longitude":  -122.3535851, "latitude": 37.9360513}
if "df_all_coords" not in st.session_state:
    st.session_state.df_all_coords = []

with st.sidebar:

    with st.container(border=True):
        st.markdown('<h1 style="text-align: center;font-size: 2.5em;">Find My Safe Haven</h1>',
                    unsafe_allow_html=True)
        st.image('images/findmy-icon.png')
    with st.container(border=True):
        st.markdown("### About")
        st.markdown('''
        This webapp is designed to help you find the nearest police station, fire station, hospital, food bank and church in your area. 
        ''')

    with st.container(border=True):
        st.markdown("### Choose how to search")
        search_type = st.radio("Search by", ["City and State", "FIPS Code", "Current Location"])



    if search_type == "City and State":
        st.session_state.df_all_coords = []

        with st.form(key='my_form'):
            city = st.text_input("Enter the city you want to search for")
            state = st.selectbox("Select State", ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"])


            city = city.upper()
            state = state.upper()


            if st.form_submit_button("Search", use_container_width=True, type="primary"):
                if os.path.exists('map.html'):
                    os.remove('map.html')


                church_json = get_church_data(city, "", state)
                st.session_state.church_json = church_json["av_churchquery.1Response"]["Results"]["result_1"]["Row"]


                food_json = get_food_data(city, "", state)
                st.session_state.food_json = food_json["av_foodbankquery.1Response"]["Results"]["result_1"]["Row"]


                fire_json = get_fire_data(city, "", state)
                st.session_state.fire_json = fire_json["av_firequery.1Response"]["Results"]["result_1"]["Row"]


                hospital_json = get_hospital_data(city, "", state)
                st.session_state.hospital_json = hospital_json["av_hospitalquery.1Response"]["Results"]["result_1"]["Row"]


                police_json = get_police_data(city, "", state)
                st.session_state.police_json = police_json["av_policequery.1Response"]["Results"]["result_1"]["Row"]


                core_json =  get_core_data(city, "", state)
                st.session_state.core_json = core_json["av_corequery.1Response"]["Results"]["result_1"]["Row"]

                st.session_state.json_list = [church_json, food_json, fire_json, hospital_json, police_json, core_json]


                # {'av_churchquery.1Response': {'sequence': 0, 'Results': {'result_2': {'Row':
                # json_file = get_food_data(city, "", state)
                # json_string = json_file["av_churchquery.1Response"]["Results"]["result_1"]["Row"]
                # st.session_state.json_string = json_string


    if search_type == "FIPS Code":
        st.session_state.df_all_coords = []

        with st.container(border=True):
            fips = st.text_input("Enter the FIPS code")
            #state = st.selectbox("Select State", ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"])

        fips = fips.upper()
        #state = state.upper()

        with st.sidebar:
            if st.button("Search", use_container_width=True, type="primary"):

                church_json = get_church_data("", fips, "")
                st.session_state.church_json = church_json["av_churchquery.1Response"]["Results"]["result_2"]["Row"]

                food_json = get_food_data("", fips, "")
                st.session_state.food_json = food_json["av_foodbankquery.1Response"]["Results"]["result_2"]["Row"]

                fire_json = get_fire_data("", fips, "")
                st.session_state.fire_json = fire_json["av_firequery.1Response"]["Results"]["result_2"]["Row"]

                hospital_json = get_hospital_data("", fips, "")
                st.session_state.hospital_json = hospital_json["av_hospitalquery.1Response"]["Results"]["result_2"]["Row"]

                police_json = get_police_data("", fips, "")
                st.session_state.police_json = police_json["av_policequery.1Response"]["Results"]["result_2"]["Row"]

                core_json =  get_core_data("", fips, "")
                st.session_state.core_json = core_json["av_corequery.1Response"]["Results"]["result_2"]["Row"]

                st.session_state.json_list = [church_json, food_json, fire_json, hospital_json, police_json, core_json]


    if search_type == "Current Location":
        location = streamlit_geolocation()
        geolocator = Nominatim(user_agent="geoapiExercises")
        lat = location['latitude']
        lon = location['longitude']
        location = geolocator.reverse([lat, lon])
        city = location.raw['address']['city']
        state = location.raw['address']['state']
        city = city.upper()
        state = state.upper()

        with st.sidebar:
            if st.button("Search", use_container_width=True):

                church_json = get_church_data(city, "", state)
                st.session_state.church_json = church_json["av_churchquery.1Response"]["Results"]["result_1"]["Row"]

                food_json = get_food_data(city, "", state)
                st.session_state.food_json = food_json["av_foodbankquery.1Response"]["Results"]["result_1"]["Row"]

                fire_json = get_fire_data(city, "", state)
                st.session_state.fire_json = fire_json["av_firequery.1Response"]["Results"]["result_1"]["Row"]

                hospital_json = get_hospital_data(city, "", state)
                st.session_state.hospital_json = hospital_json["av_hospitalquery.1Response"]["Results"]["result_1"]["Row"]

                police_json = get_police_data(city, "", state)
                st.session_state.police_json = police_json["av_policequery.1Response"]["Results"]["result_1"]["Row"]

                core_json =  get_core_data(city, "", state)
                st.session_state.core_json = core_json["av_corequery.1Response"]["Results"]["result_1"]["Row"]

                st.session_state.json_list = [church_json, food_json, fire_json, hospital_json, police_json, core_json]

if st.session_state.core_json != "" and st.session_state.core_json != []:
    state_col, county_col = st.columns([1, 1])
    with state_col:
        with st.container(border=True):
            state_val = st.session_state.core_json[0]['state_name']
            st.markdown("### State")
            st.markdown(f'### {state_val}')
    with county_col:
        with st.container(border=True):
            county_val = st.session_state.core_json[0]['county_name']
            st.markdown("### County")
            st.markdown(f'### {county_val}')
col1, col2 = st.columns([2, 1])

if st.session_state.core_json != "" and st.session_state.core_json != []:
    with st.container(border=True):
        st.markdown("## About the Area")
        df_core = convert_to_df(st.session_state.core_json)
        edu, pov, cri, tot = st.session_state.core_json[0]['educationscore'], st.session_state.core_json[0]['povertyscore'], st.session_state.core_json[0]['crimescore'], st.session_state.core_json[0]['finalscore']
        c1, c2, c3, c4 = st.columns(4)
        with c1:
            with st.container(border=True):
                st.markdown("### Education Score")
                st.metric(label="Education Score", value=edu)
        with c2:
            with st.container(border=True):
                st.markdown("### Poverty Score")
                st.metric(label="Poverty Score", value=pov)
        with c3:
            with st.container(border=True):
                st.markdown("### Crime Score")
                st.metric(label="Crime Score", value=cri)

        with c4:
            with st.container(border=True):
                st.markdown("### Risk Index")
                st.metric(label="Risk Index", value=tot)


        if tot == 0:
            st.markdown("""
                           <div style='background-color: #262730; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
                               INADEQUATE DATA
                           </div>
                           """, unsafe_allow_html=True)
            st.markdown("")
        elif tot < 10:

            st.markdown("""
                           <div style='background-color: #008000; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
                               AREA IS SAFE
                           </div>
                           """, unsafe_allow_html=True)
            st.markdown("")
        elif tot >= 10 and tot < 20:
            st.markdown("""
                           <div style='background-color: #ffbd45; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
                               AREA IS LOW RISK
                           </div>
                           """, unsafe_allow_html=True)
            st.markdown("")

        elif tot >= 20 and tot < 40:
            st.markdown("""
                           <div style='background-color: #ff8011; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
                               AREA IS MEDIUM RISK
                           </div>
                           """, unsafe_allow_html=True)
            st.markdown("")
        else:
            st.markdown("""
                                       <div style='background-color: #ff4b4b; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
                                           AREA IS HIGH RISK 
                                       </div>
                                       """, unsafe_allow_html=True)
            st.markdown("")


        with st.expander("More Information"):

            danger_index_df = pd.DataFrame({
                "Risk Index": ['0', '<10', '10-20', '20-40', '>40', 'Total'],
                "Number of Cities": ['184', '5401', '14941', '9766', '552', '30844'],
                "Percentage of Cities": ['0.6%', '17.5%', '48.5%', '31.7%', '1.8%', '100%'],
                "Zone": ["Inadequate data", "Safe", "Low Risk", "Medium Risk", "High Risk", ''],
            })

            st.markdown("### Risk Index")
            st.markdown("The risk index is a measure of the overall risk of the area. It is calculated based on the education, poverty and crime scores. The lower the safety index, the safer the area is.")
            st.dataframe(danger_index_df, use_container_width=True, hide_index=True)
            st.dataframe(df_core, hide_index=True, use_container_width=True)

if st.session_state.police_json != "" and st.session_state.police_json != []:
    with st.container(border=True):
        st.markdown("## Nearest Police Station")
        pol_col, tele_col = st.columns([1, 1])
        with pol_col:
            with st.container(border=True):
                st.markdown("### Name")
                pol_name = st.session_state.police_json[0]['police_name']
                st.markdown(f'### {pol_name}')
        with tele_col:
            with st.container(border=True):
                st.markdown("### Telephone")
                pol_tele = st.session_state.police_json[0]['telephone']
                st.markdown(f'### {pol_tele}')
        df_police = convert_to_df(st.session_state.police_json)
        df_police_coords = df_police[['ycoor', 'xcoor']]
        df_police_coords.rename(columns={'ycoor': 'latitude', 'xcoor': 'longitude'}, inplace=True)
        df_police_coords['type'] = 'Police Station'
        if len(df_police_coords) > 5:
            st.session_state.df_all_coords.append(df_police_coords.head(5))
        else:
            st.session_state.df_all_coords.append(df_police_coords)
        st.dataframe(df_police, use_container_width=True, hide_index=True)
# else:
#     st.markdown("""
#                                <div style='background-color: #262730; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
#                                    NO DATA AVAILABLE FOR POLICE STATION
#                                </div>
#                                """, unsafe_allow_html=True)
#     st.markdown("")


if st.session_state.fire_json != "" and st.session_state.fire_json != []:
    with st.container(border=True):
        st.markdown("## Nearest Fire Station")
        df_fire = convert_to_df(st.session_state.fire_json)
        st.dataframe(df_fire, use_container_width=True, hide_index=True)
# else:
#     st.markdown("""
#                                    <div style='background-color: #262730; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
#                                        NO DATA AVAILABLE FOR FIRE STATION
#                                    </div>
#                                    """, unsafe_allow_html=True)
#     st.markdown("")

if st.session_state.hospital_json != "" and st.session_state.hospital_json != []:
    with st.container(border=True):
        st.markdown("## Nearest Hospital")
        hosp_col, telehosp_col = st.columns([1, 1])
        with hosp_col:
            with st.container(border=True):
                st.markdown("### Name")
                hosp_name = st.session_state.hospital_json[0]['hospital_name']
                st.markdown(f'### {hosp_name}')
        with telehosp_col:
            with st.container(border=True):
                st.markdown("### Telephone")
                hosp_tele = st.session_state.hospital_json[0]['telephone']
                st.markdown(f'### {hosp_tele}')
        df_hospital = convert_to_df(st.session_state.hospital_json)
        df_hospital_coords = df_hospital[['ycoor', 'xcoor']]
        df_hospital_coords.rename(columns={'ycoor': 'latitude', 'xcoor': 'longitude'}, inplace=True)
        df_hospital_coords['type'] = 'Hospital'
        if len(df_hospital_coords) > 5:
            st.session_state.df_all_coords.append(df_hospital_coords.head(5))
        else:
            st.session_state.df_all_coords.append(df_hospital_coords)
        st.dataframe(df_hospital, use_container_width=True, hide_index=True)
# else:
#     st.markdown("""
#                                        <div style='background-color: #262730; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
#                                            NO DATA AVAILABLE FOR HOSPITAL
#                                        </div>
#                                        """, unsafe_allow_html=True)
#     st.markdown("")

if st.session_state.food_json != "" and st.session_state.food_json != []:
    with st.container(border=True):
        st.markdown("## Nearest Food Bank")
        print(type(st.session_state.food_json))
        df_food_bank = convert_to_df(st.session_state.food_json)
        df_food_bank_coords = df_food_bank[['ycoor', 'xcoor']]
        df_food_bank_coords.rename(columns={'ycoor': 'latitude', 'xcoor': 'longitude'}, inplace=True)
        df_food_bank_coords['type'] = 'Food Bank'
        if len(df_food_bank_coords) > 5:
            st.session_state.df_all_coords.append(df_food_bank_coords.head(5))
        else:
            st.session_state.df_all_coords.append(df_food_bank_coords)
        st.dataframe(df_food_bank, use_container_width=True, hide_index=True)

#
# else:
#     st.markdown("""
#                                            <div style='background-color: #262730; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
#                                                NO DATA AVAILABLE FOR FOOD BANK
#                                            </div>
#                                            """, unsafe_allow_html=True)
#     st.markdown("")
if st.session_state.church_json != "" and st.session_state.church_json != []:
    with st.container(border=True):
        st.markdown("## Nearest Church")
        df_church = convert_to_df(st.session_state.church_json)
        df_church_coords = df_church[['ycoor', 'xcoor']]
        df_church_coords.rename(columns={'ycoor': 'latitude', 'xcoor': 'longitude'}, inplace=True)
        df_church_coords['type'] = 'Church'
        if len(df_church_coords) >5:
            st.session_state.df_all_coords.append(df_church_coords.head(5))
        else:
            st.session_state.df_all_coords.append(df_church_coords)
        st.dataframe(df_church, use_container_width=True, hide_index=True)

# else:
#     st.markdown("""
#                                                <div style='background-color: #262730; padding: 20px; border-radius: 5px; text-align: center; font-size: 20px; '>
#                                                    NO DATA AVAILABLE FOR CHURCH
#                                                </div>
#                                                """, unsafe_allow_html=True)
#     st.markdown("")

if st.session_state.df_all_coords != []:
    df_all_coords = pd.concat(st.session_state.df_all_coords, axis=0)

    # Display the coordinates on a map
    #st.map(df_all_coords)
    #df_all_coords = pd.concat([df_police_coords, df_hospital_coords, df_food_bank_coords, df_church_coords], axis=0)
    df_all_coords = df_all_coords.dropna()
    df_all_coords = df_all_coords.reset_index(drop=True)
    m = folium.Map(location=[df_all_coords['latitude'].iloc[0], df_all_coords['longitude'].iloc[0]], zoom_start=13)
    for index, row in df_all_coords.iterrows():
        # Choose an icon based on the type of location
        if row['type'] == 'Police Station':
            icon_name = 'shield'
            icon_color = 'black'
        elif row['type'] == 'Hospital':
            icon_name = 'bed'
            icon_color = 'red'
        elif row['type'] == 'Food Bank':
            icon_name = 'cutlery'
            icon_color = 'green'
        elif row['type'] == 'Church':
            icon_name = 'church'
            icon_color = 'purple'
        else:
            icon_name = 'info-sign'
            icon_color = 'blue'# Default icon

        folium.Marker(
            location=[row['latitude'], row['longitude']],
            popup=row['type'],  # Add a popup with the type of location
            icon=folium.Icon(icon=icon_name, prefix='fa', color=icon_color),  # Use the chosen icon
        ).add_to(m)

    # Save the map to an HTML file
    m.save('map.html')

    # Display the HTML file in the Streamlit app

    if df_all_coords.empty:
        pass
    else:
        with col1:
            with st.container(border=True):
                st.components.v1.html(open('map.html', 'r+').read(), height=600)
                #st.map(df_all_coords, use_container_width=True)

# if st.session_state.location['latitude']:
#     location = st.session_state.location
#     df_lat_long = pd.DataFrame({
#         'lat': [loc[]],
#         'lon': [location['longitude'], location['longitude'] + 0.0001],
#         'info': ['A', 'B']
#     })
#     with col1:
#         st.map(df_lat_long)

with col2:
    BASE_PROMPT = "You will be provided with data about the nearest police station, you will need to provide a summary of the data in a concise and informative manner. Use bullet points and avoid repeating information. Here is the data you need to summarize: " + str(st.session_state.police_json)
    model = genai.GenerativeModel('gemini-pro')
    with st.container(border=True, height=640):
        chat_page_fn(model, BASE_PROMPT)
#
#
