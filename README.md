# Maryland 2024 Voter Participation Analysis

## Project Overview

This project analyzes voter participation across Maryland jurisdictions during the 2024 Presidential General Election.

The analysis examines participation rates, jurisdiction size, voting methods, and precinct/polling-place structure to identify meaningful differences in voter participation across Maryland.

## Stakeholder Question

How did voter participation vary across Maryland in the 2024 Presidential General Election, and what characteristics of counties or precincts are associated with differences in participation?

## Tools

- SQL / BigQuery
- Tableau
- GitHub
- Excel

## Data Sources

- Maryland 2024 Presidential General Election Results
- Maryland 2024 Voter Registration Counts
- Maryland 2024 State Precinct Reference

## Methodology

The analysis followed the workflow:

**Understand → Validate → Connect → Define → Analyze → Communicate**

SQL was used in BigQuery to validate the datasets, establish relationships between tables, calculate participation metrics, and investigate differences across Maryland jurisdictions.

Tableau was used to communicate the findings through interactive visualizations.

## Key Findings

- Voter participation varied substantially across Maryland jurisdictions.
- Talbot County had the highest participation rate at 80.08%, while Baltimore City had the lowest at 57.76%.
- Jurisdiction size showed a modest negative relationship with participation rate, with an R² of approximately 14%.
- Voting-method patterns did not show a consistent relationship with participation differences across jurisdictions.
- Precinct and polling-place structure also did not show a clear, consistent relationship with participation rates.

## Limitations

- Voter registration data was available at the county/jurisdiction level rather than the precinct level.
- The analysis identifies associations and patterns but does not establish causation.
- The precinct reference data contained some records without a populated precinct identifier.
  
## Dashboard

Explore the interactive Tableau dashboard:

[View the Maryland 2024 Voter Participation Dashboard](https://public.tableau.com/app/profile/fatina.crabbe/viz/Maryland2024VoterParticipationAnalysis/Maryland2024VoterParticipationDashboard)

## Project Files

This repository contains the project documentation and analysis materials used to develop the findings.
