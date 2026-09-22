# Tasty Bytes dbt Project

Welcome to the Tasty Bytes dbt project.

## Getting started

Use the **Compile** and **Run** buttons in the bottom pane to execute the project.

On the first run, click **Compile** first to set up the raw data tables, then click **Run**
to build the models. The Tasty Bytes dataset was created to model production dataset sizes,
so the initial data load takes between 5–10 minutes. After this initial setup, subsequent
runs are fast.

## Project structure

| Path | Description |
|---|---|
| `models/staging/` | Raw source views over the loaded tables |
| `models/marts/` | Business-logic models (SQL + Snowpark Python) |
| `macros/` | `create_raw_tables()` loads source data on first run |
| `profiles.yml` | Connection config — edit to change your target database/schema |
| `examples/` | Sample queries to explore the dataset |
