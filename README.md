# FindMySafeHaven

Many travelers find themselves in unfamiliar cities, sometimes unexpectedly. Without knowing the risks and dangers in those areas, tourists can find themselves in dangerous situations. FindMySafeHaven helps travelers stay informed about the safety of their surroundings by providing critical information on social factors and nearby resources. This tool aims to enhance safety and peace of mind for travelers in unfamiliar places.

## Challenge Overview

This year’s challenge was to analyze different social factors by area, such as poverty, unemployment, and education, to assess the risk for travelers in unfamiliar locations and help them find safe resources.

### Goals:
1. **Analysis of Social Factors:** Analyze social factors (unemployment, education, poverty, and population) to identify "Hot Spots."
2. **Safe Haven Resources:** Provide travelers with information to find nearby safe resources (police stations, fire stations, hospitals, churches, food banks, etc.).

## Solution

### Data Collection
- Collected City and County Data from all 50 US states.
- Integrated multiple public datasets, which were cleaned and prepared for analysis using HPCC Systems.

### Features
- **ROXIE Query:** Data is delivered to users via a ROXIE query, fetching data by FIPS Code or City & State using a REST API.
- **User Input:** Users can enter their location using their current city and state or the FIPS Code.
- **Resource Mapping:** The website displays nearby resources (police stations, fire stations, food banks, hospitals, and churches) on a map using latitude and longitude data.
- **Risk Index Display:** Data is presented in tables and displays the Risk Index, classifying the area as Low, Medium, or High Risk.
- **LLM Integration:** An LLM summarizes all available nearby resources using Google’s Gemini LLM.

### Risk Index Calculation
- Calculated a Risk Index Score for each city by analyzing three social factors:
  - **CrimeScore:** Total crimes per 100,000 in a county.
  - **EduScore:** Percentage of adults with less than a high school diploma.
  - **PovertyScore:** Percentage of people living in poverty.

### Implementation
- **HPCC Systems and ECL:** Used HPCC Systems' powerful data processing capabilities. Data was loaded and cleaned using the ECL (Enterprise Control Language) on the THOR cluster and delivered via ROXIE.
- **Resource Linkage:** Linked all resources (police stations, hospitals, fire stations, food banks, and churches) to the Risk Index Table by FIPS Code.
- **ROXIE Query Delivery:** Data was delivered using a ROXIE query fetching by FIPS Code or City & State.
- **Web Interface:** Created the web interface using Streamlit and Python, displaying the Risk Index Score along with the nearest resources on the FindMySafeHaven website.
  - **Gemini Integration:** Integrated Google’s Gemini LLM to power the chatbot, which provides users with a summarized view of nearby resources.

# How to Install and Use FindMySafeHaven Streamlit App

## Prerequisites:
- Python installed on your system (version 3.6 or higher).
- pip package manager installed.

## Installation Steps:
1. **Clone the repository:**

   ```bash
   git clone https://github.com/CubeStar1/HPCC-Hackathon-2024-FindMySafeHaven.git
   cd HPCC-Hackathon-2024-FindMySafeHaven

2. **Install dependencies:**

   ```bash
   pip install -r requirements.txt
   
### How to Use
1. **Run the Streamlit app:**

   ```bash
    streamlit run app2.py
2. **Open the WebUI in your browser:** 

   - Open your web browser and navigate to http://localhost:8501 to use the WebUI.
3. You can now use the FindMySafeHaven app by following the instructions provided on the web interface:
  - Enter your location using your city and state or FIPS Code.
  - View the map displaying nearby resources.
  - Check the tables for detailed data and the Risk Index classification.
  - Use Gemini for a summarized view of nearby resources.

## Technologies Used
- **HPCC Systems**
  - **THOR:** For data loading and cleaning.
  - **ROXIE:** For delivering data via queries.
  - **ECL (Enterprise Control Language):** For data processing.
- **Google’s Gemini LLM**
- **REST API**
- **Streamlit:** For creating the web interface.
- **Python:** For backend development.

