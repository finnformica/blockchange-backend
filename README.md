# BlockChange Back-End

The back-end repo for BlockChange - a distributed crowdfunding application for humanitarian causes. Built using Solidity for use on the Ethereum blockchain this repo contains the smart contract factory and contract for deploying and managing individual humanitarian campaigns.

## Dependencies

- Python 3.9+
- Ganache 7.7+

## Getting Started

1. Clone the repo:

```bash
git clone https://github.com/finnformica/blockchange-backend.git
```

2. Setup python environment and install requirements:
```bash
cd blockchange-backend
python3 -m venv venv
pip3 install -r requirements.txt
```

3. Start ganache sever to create a local blockchain:
```bash
ganache
```

4. Compile and deploy contract factory - the script also deploys four sample causes for testing:
```bash
python3 compile-local.py
```

## Features

- Ability to create humanitarian cause using the contract factory.
- Admins can update permissions for other address.
- Storing of all donations for transparency.
- Cause can be toggled between 'active' and 'inactive'.
- Inactive causes can have remaining funds redistributed.