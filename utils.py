import requests
import pandas as pd
import json
from geopy.geocoders import Nominatim, Photon

def get_person_data(fname, lname, gender, state):
    url = f"http://training.us-hpccsystems-dev.azure.lnrsg.io:8002/WsEcl/submit/query/roxie/bobf.peoplefilesearchservice.1/json?firstname={fname}&lastname={lname}&sex={gender}&state={state}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        error = "Unable to get person data. Please try again."
        return error


def convert_to_df(json_string):
    df = pd.DataFrame(json_string)
    return df


def get_church_data(city, fips, state):
    url = f"http://training.us-hpccsystems-dev.azure.lnrsg.io:8002/WsEcl/submit/query/roxie/av_churchquery.1/json?cityval={city}&fipsval={fips}&stateval={state}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        error = "Unable to get person data. Please try again."
        return error

#print(get_church_data("LAWRENCE", "25009", "MA"))

def get_food_data(city, fips, state):
    url = f"http://training.us-hpccsystems-dev.azure.lnrsg.io:8002/WsEcl/submit/query/roxie/av_foodbankquery.1/json?cityval={city}&fipsval={fips}&stateval={state}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        error = "Unable to get person data. Please try again."
        return error

#print(get_food_data("WALLINGFORD", "", "CT"))



def get_fire_data(city, fips, state):
    url = f"http://training.us-hpccsystems-dev.azure.lnrsg.io:8002/WsEcl/submit/query/roxie/av_firequery.1/json?cityval={city}&fipsval={fips}&stateval={state}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        error = "Unable to get person data. Please try again."
        return error

def get_hospital_data(city, fips, state):
    url = f"http://training.us-hpccsystems-dev.azure.lnrsg.io:8002/WsEcl/submit/query/roxie/av_hospitalquery.1/json?cityval={city}&fipsval={fips}&stateval={state}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        error = "Unable to get person data. Please try again."
        return error


def get_police_data(city, fips, state):
    url = f"http://training.us-hpccsystems-dev.azure.lnrsg.io:8002/WsEcl/submit/query/roxie/av_policequery.1/json?cityval={city}&fipsval={fips}&stateval={state}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        error = "Unable to get person data. Please try again."
        return error

def get_core_data(city, fips, state):
    url = f"http://training.us-hpccsystems-dev.azure.lnrsg.io:8002/WsEcl/submit/query/roxie/av_corequery.1/json?cityval={city}&fipsval={fips}&stateval={state}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        error = "Unable to get person data. Please try again."
        return error


def get_city_and_state_from_lat_long(latitude, longitude):
    geolocator = Photon(user_agent="geoapiExercises")
    latitude, longitude = str(latitude), str(longitude)
    location = geolocator.reverse(latitude + "," + longitude)
    address = location.raw['address']
    city = address.get('city', '')
    state = address.get('state', '')
    country = address.get('country', '')
    print('City:', city)
    print('State:', state)
    print('Country:', country)
    return city, state




# print(get_church_data("LAWRENCE", "25009", "MA"))
# print(get_food_data("WALLINGFORD", "", "CT"))
# print(get_fire_data("WALLINGFORD", "", "CT"))
# print(get_hospital_data("WALLINGFORD", "", "CT"))
# print(get_police_data("WALLINGFORD", "", "CT"))
# print(get_core_data("LAWRENCE", "25009", "MA"))

