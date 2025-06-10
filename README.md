# 🐾 ZOO Database Project – `PROJEKT.sql`

## 📋 Overview

This SQL project defines a relational database for managing a **zoo's operations and data**. It covers animals, enclosures, staff, visitors, ticketing, shows, food types, and spatial organization. The schema is enriched with **constraints, triggers, views, and stored functions** to ensure data integrity and support core business logic.

## 🗃️ Core Components

### **Tables**

* **`areny`**
  Contains zones (arenas) within the zoo.

* **`mapa`**
  Represents locations (restaurants, attractions, etc.) tied to specific arenas.

* **`rodzaje_pozywienia`**
  Enumerates food types used in animal enclosures.

* **`wybiegi`**
  Represents enclosures, each linked to an arena and food type.

* **`zwierzeta`**
  Stores animals with attributes like species, birthdate, and assigned enclosure.

* **`nazwy_specjalizacji`**
  Enumerates caretaker specializations (e.g., veterinarian, zoologist).

* **`opiekunowie`**
  Tracks caretakers, their details, and optional specialization.

* **`zwierzeta_opiekunowie`**
  Many-to-many relation between animals and caretakers.

* **`pokazy`**
  Manages scheduled shows including name, date, time, and enclosure.

* **`odwiedzajacy`**
  Stores visitor data (name, surname, email).

* **`rodzaje_biletow`**
  Lists ticket types with their base prices.

* **`kasa`**
  Records ticket purchases, including donation info and final price.

* **`opinie`**
  Enables visitors to submit zoo ratings (0–10), restricted to those who’ve purchased a ticket.

### **Triggers & Business Logic**

* **`cena_biletu_trigger`**
  Automatically calculates the final ticket price based on donation status.

* **`sprawdz_czy_bilet_trigger`**
  Ensures only ticket-holders can leave opinions.


## 🧪 Sample Data

The script includes example data for:

* Visitors, arenas, enclosures, shows
* Ticket types and purchases
* Animal and caretaker assignments
* Opinions and ticket purchases

These provide a **fully functional demo** for testing queries and views.

## ✅ Highlights

* Data integrity ensured with **foreign keys and cascading rules**
* **Triggers and functions** automate pricing and access control
* Designed for **expandability and real-world simulation**
* Cleanly organized to support interface development

## 📂 Project Structure

The project includes two SQL files that together create the database: one defines the structure of the tables, and the other contains sample data for testing and demonstration purposes. Additionally, there are two R scripts that build the user interface: one handles the UI layout, and the other manages the server-side logic for rendering outputs and handling user input.
