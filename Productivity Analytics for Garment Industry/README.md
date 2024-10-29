# Productivity Analytics for Garment Industry

## Project Overview
This project applies business intelligence and data analytics techniques to predict productivity levels in the garment industry using machine learning. We analyzed the "Productivity Prediction of Garment Employees" dataset to understand factors that impact productivity and to develop a predictive model that could support decision-making in optimizing workforce efficiency. The project follows the CRISP-DM framework, covering phases from business understanding to deployment recommendations.

**Note**: The code was developed and tested in Google Colab. If running in a different environment, ensure compatibility by checking for potential differences in data type handling, NaN processing, and random states.

## Objectives
The key objectives of this project were:
1. **Business Understanding**: Define the scenario, business objectives, and success criteria for improving garment manufacturing productivity.
2. **Data Understanding**: Document attribute types, statistical properties, data quality, and potential biases. Visualize data distributions and correlations.
3. **Data Preparation**: Create derived attributes, clean and preprocess data, and prepare it for model input.
4. **Modeling**: Develop and tune a machine learning model for predicting productivity, focusing on metrics such as MAE, MSE, RMSE, and MAPE.
5. **Evaluation**: Assess model performance against benchmarks, baseline metrics, and predefined business success criteria.
6. **Deployment**: Offer recommendations for deploying the model, including potential risks, ethical aspects, and monitoring triggers.

## Key Features

- **Garment Productivity Prediction**: A machine learning model that predicts productivity levels based on team size, task type, and other workforce variables.
- **Data Quality and Bias Assessment**: Examines potential biases in productivity data to ensure fair and representative results.
- **Ethical and Deployment Considerations**: Provides deployment strategies while addressing ethical implications, such as bias toward specific departments.

## Contents of the Project Folder

- **report.pdf**: A comprehensive report detailing each stage of the project, from business understanding to deployment, following the CRISP-DM framework.
- **analysis.ipynb**: Jupyter notebook containing the full code for data processing, model training, evaluation, and visualization. The notebook is structured for reproducibility, with clear documentation and code comments.

## Tools
   - **Python (Scikit-Learn)**: Used for data preprocessing, modeling, and evaluation.
   - **Google Colab**: Development and testing environment. Note that compatibility with other environments may require checking data type handling, NaN processing, and random states.
   - **Matplotlib/Seaborn**: Used to create visualizations that summarize findings and model performance.

## Running the Solution
   - Ensure dependencies are installed (e.g., `scikit-learn`, `pandas`, `matplotlib`). The required packages are listed in the notebook.
   - Open `analysis.ipynb` in Jupyter or Google Colab to run the code. All steps, from data preparation to model evaluation, are executed within the notebook.

## Contributors
- [Thomas Laner](https://github.com/thomaslaner)
- [Manuel Oberbacher](https://github.com/mnlbrb)

---

This project demonstrates skills in business intelligence and data analytics, using machine learning to derive actionable insights in the garment industry. Users are encouraged to explore the code, reproduce results, and adapt the solution to other datasets.