Check out the live website for this project here 👉 https://supply-chain-blockchain.netlify.app/

🏥 Pharma Supply Chain – Blockchain-Based Traceability System

A robust, production-grade pharmaceutical supply chain management smart contract built using Solidity, designed to ensure end-to-end traceability, role-based access control, counterfeit prevention, and patient safety.

This project demonstrates strong skills in smart contract architecture, secure state management, event-driven design, and real-world system modeling—aligned with what top software engineering teams look for.

🌟 Key Highlights
🔐 Role-Based Access Control Architecture

Implements a secure and scalable RBAC model:

Manufacturer

Distributor

Pharmacy

Patient

Roles can only be assigned by the contract owner, ensuring controlled onboarding and preventing privilege escalation.

📦 Medicine Asset Management

Each medicine is represented as a structured on-chain asset containing:

Product ID (unique)

Serial number (unique)

Manufacturing date

Expiry date

Current owner

Transfer timestamps

Transfer history (full audit trail)

The system prevents duplication and enforces strict validation rules.

🔗 End-to-End Supply Chain Flow

Fully recorded and verified transitions:

Manufacturer → Distributor

Distributor → Pharmacy

Pharmacy → Patient

Each transfer emits a TransferRecorded event, enabling off-chain indexing and transparent auditing.

🛡️ Patient-Centric Safety Features

Patients can:

View the complete ownership chain

Verify medicine status:

Valid

Expired

Rejected

Reject a medicine if it appears unsafe or suspicious

This promotes accountability and prevents counterfeit distribution.

🛠️ Engineering & Design Principles Demonstrated
Clean Contract Structure

Clear separation of concerns with dedicated modifiers, mappings, events, and structs.

Secure State Transitions

Only the current owner of a medicine can initiate a transfer.
Prevents unauthorized modifications or misuse.

Efficient Data Storage

Uses mappings and compact structs for gas-efficient read/write operations.

Event-Driven Logging

Every transfer is logged using indexed events for efficient filtering and blockchain analytics.

Production-Level Validations

Enforces unique product IDs

Ensures expiry > manufacture date

Blocks creation of expired medicines

Validates recipient role at every step

🧰 Tech Stack

Solidity (v0.8.28)

EVM-compatible blockchain

Designed for integration with:

Hardhat

Foundry

Truffle

React/Next.js Frontend

Standard-compliant: MIT Licensed
