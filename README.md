# README lab-template
Lab Repository Template
This document outlines the standard structure and content for all research code repositories within our lab. Creating a template repository with these files ensures consistency, promotes open science, and makes your work citable and sustainable.
Every project in the lab will have a README.md, LICENSE, and CITATION.cff in the exact same place.

1. README.md
The README.md is the face of your repository. It should be clear enough for a new student to start using the code without asking you for help.
  - Title and Description: A brief explanation of what the code does and the research problem it addresses.
  - Installation: Step-by-step instructions (e.g., "Clone the repo," "Install requirements via pip install -r requirements.txt").
    -  For Python: Include a blank requirements.txt or environment.yml.
    -  For MATLAB: Include a README.md section titled "Toolbox Dependencies" where they list required toolboxes.
    -  For Julia: Include a Project.toml file.
  - Usage: A simple example script or command to demonstrate the code in action.
  - Citation: Explicit instructions on how to cite this work. Include the Zenodo DOI here once it is generated.
  - Contributing: Briefly mention if you accept contributions and how to submit a Pull Request.

3. CITATION.cff
The CITATION.cff (Citation File Format) is a human- and machine-readable file that tells others exactly how to attribute your work.
  - cff-version: 1.2.0
  - message: "If you use this software, please cite it as below."
  - authors:
  - family-names: "Goodman"
  - given-names: "Saul"
  - orcid: "https://orcid.org/0000-0000-0000-0000"
  - title: "Your Project Title"
  - version: 1.0.0
  - date-released: 2026-05-26
In your CITATION.cff template, you can leave the funding or notes field open, or add a FUNDING.md file if there are complex grant requirements.


3. LICENSE
A license tells the community how they can use your work. Without one, the code is under exclusive copyright, and others cannot legally use or modify it.
  - MIT License: Very permissive. Good if you want your code to be widely adopted with minimal restrictions.
  - Apache License 2.0: Similar to MIT but includes an explicit grant of patent rights.
  - GNU GPLv3: "Copyleft." Ensures that any derivative work must also be open-source. Choose this if you want to ensure the code remains open forever.

4. Contributing Guide (CONTRIBUTING.md)
Outline the expectations for students:
  - Use Pull Requests for all changes.
  - Include tests for new functionality.
  - Keep the documentation updated.
