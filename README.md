# Import-Export Management System for Netherlands Port

A web-based application designed to manage import-export operations at the Netherlands port. Customers can order products, track orders, update profiles, and report faulty products. Sellers can manage inventory, process orders, update order status, and resolve reported issues.

---

## 🌐 Features

### Customer Features
- Register and log in
- Browse and order products
- Track order status
- Update profile information
- Report faulty products

### Seller Features
- Manage inventory (add, update, delete products)
- Process and update order status
- View and resolve reported issues

---

## 🛠 Technologies Used

- **Frontend:** JSP, Bootstrap, JavaScript  
- **Backend:** Java, Servlets  
- **Database:** MySQL  
- **Web Server:** Apache Tomcat  
- **Build Tool:** Maven or Gradle  

---

## 🚀 Setup Instructions

### ✅ Prerequisites
- Java Development Kit (JDK): Version 8 or higher  
- Apache Tomcat: Version 9 or higher  
- MySQL: Version 5.7 or higher  
- Eclipse IDE (or any Java IDE)  
- Git  

---

### 📦 Steps to Run the Project

1. **Clone the Repository**

```bash
git clone https://github.com/your-username/import-export-management-system.git
cd import-export-management-system
import-export-management-system/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/
│   │   │       ├── controller/    # Servlets
│   │   │       ├── dao/           # Data Access Layer
│   │   │       ├── model/         # Java Beans (User, Product, Order)
│   │   │       ├── util/          # Utility Classes (e.g., DB connection)
│   │   ├── webapp/
│   │   │   ├── files.jsp
│   │   │   ├── register.html
├── test/                          # Unit Tests
├── database/
│   └── db.sql                     # SQL schema and sample data
├── pom.xml                        # Maven build configuration

---

Let me know if you want this as a downloadable `.md` file or want to include badges, screenshots, or deployment steps for cloud platforms.
