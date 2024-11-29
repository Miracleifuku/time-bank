# Decentralized Time Banking Smart Contract

## Overview

This smart contract facilitates a **Decentralized Time Banking System** that allows users to exchange services based on time credits rather than money. Users can register, create service offerings, and exchange services using the platform. All transactions and user profiles are stored on-chain for transparency and security.


## Features

### 1. **User Management**
   - **Register User**: New users can register and define their skills.
   - **Update Skills**: Registered users can update their list of skills.
   - **Profile Management**: Track user credits, skills, and reputation scores.

### 2. **Service Offerings**
   - **Create Service Offerings**: Users can advertise services, specifying skills, hours offered, and descriptions.
   - **View Offerings**: Anyone can browse the available service offerings.

### 3. **Service Exchanges**
   - **Request Services**: Users can request time-based services and initiate exchanges.
   - **Complete Exchanges**: Providers can confirm service completion, updating credits accordingly.

### 4. **Transparency**
   - View profiles, services, and service exchanges via read-only functions.


## Data Structure

### **Maps**
1. **`user-profiles`**
   - Stores user details such as total credits, skills, and reputation score.
2. **`service-offerings`**
   - Tracks services offered by users, including skill domain, hours available, rate, and description.
3. **`service-exchanges`**
   - Records service transactions between users, including hours exchanged and status.

### **Data Variables**
1. **`next-service-id`**
   - Tracks the next unique ID for service offerings.
2. **`next-exchange-id`**
   - Tracks the next unique ID for service exchanges.



## Key Functions

### **Public Functions**

1. **`register-user`**
   - Registers a new user with a list of skills.
   - Starts with neutral reputation (`100`) and `0` credits.

2. **`update-skills`**
   - Updates a user’s skill set.

3. **`create-service-offering`**
   - Creates a new service offering, specifying the skill domain, hours offered, and a description.
   - Rate is set at `1 credit per hour`.

4. **`exchange-service`**
   - Requests service by specifying the service ID and hours needed.
   - Records the exchange as "pending" until completed.

5. **`complete-service-exchange`**
   - Marks a pending service exchange as completed.
   - Transfers credits between the provider and the recipient.

### **Read-Only Functions**

1. **`get-user-profile`**
   - Retrieves user profile details including total credits, skills, and reputation score.

2. **`get-service-offering`**
   - Fetches details of a specific service offering.

3. **`get-service-exchange`**
   - Views details of a specific service exchange.



## Error Codes

| Code  | Description                  |
|-------|------------------------------|
| `100` | Not Authorized               |
| `101` | Insufficient Balance         |
| `102` | Service Not Found            |
| `103` | Already Exists               |
| `104` | Invalid Input                |



## Usage Workflow

1. **User Registration**
   - Call `register-user` to create an account.
   - Update skills using `update-skills`.

2. **Create Service**
   - Call `create-service-offering` to list a service.
   - Specify the skill domain, hours offered, and description.

3. **Request Service**
   - Use `exchange-service` to initiate a service request.
   - Confirm service completion with `complete-service-exchange`.

4. **View Data**
   - Use `get-user-profile`, `get-service-offering`, or `get-service-exchange` to access relevant information.



## Future Enhancements
- Implement **dynamic pricing models** based on user reputation.
- Introduce **dispute resolution mechanisms** for incomplete or disputed services.
- Allow users to **rate transactions** and **improve reputation scores**.


## License
This project is licensed under the [MIT License](https://opensource.org/licenses/MIT). 

Feel free to contribute and improve!