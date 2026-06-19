# 🚀 DAY 3 - Your Action Plan: JavaScript Advanced Concepts

**Time Required:** 4-6 hours  
**Goal:** Learn advanced JavaScript features - ES6+, Promises, Async/Await, Error Handling, and API calls

---

## 🎯 Today's Learning Objectives

By the end of today, you will understand:
- ✅ ES6+ advanced features (Template literals, Classes, Modules)
- ✅ Promises and Async/Await (handling asynchronous code)
- ✅ Error Handling (try/catch/finally)
- ✅ Fetch API (making HTTP requests)
- ✅ JSON manipulation
- ✅ How to work with APIs

---

## ✅ MORNING SESSION (2-3 hours)

### Step 1: Set Up Your Practice Environment (5 minutes)

1. **Open your JavaScript practice folder:**
   ```powershell
   cd Desktop\JavaScript-Practice
   code .
   ```

2. **Create today's practice file:**
   - In VS Code, create a new file: `day3-practice.js`
   - Save it in your JavaScript-Practice folder

---

### Step 2: Learn ES6+ Advanced Features (50-60 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/ (sections on ES6+)
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide

**What to Learn:**

1. **Template Literals:**
   - Use backticks (`` ` ``) instead of quotes
   - Interpolation with `${variable}`
   - Multiline strings

2. **Classes:**
   - Object-oriented programming in JavaScript
   - Constructors, methods, inheritance

3. **Modules (import/export):**
   - Organizing code into separate files
   - `export` and `import` statements

4. **Enhanced Object Features:**
   - Shorthand properties
   - Computed property names
   - Method shorthand

**💻 Practice Exercise 1:**
Type this code in your `day3-practice.js` file:

```javascript
// ES6+ Advanced Features Practice

console.log("=== 1. TEMPLATE LITERALS ===");

// Old way (concatenation)
let name = "VIRTUOMATE";
let age = 3;
let oldWay = "Hello, " + name + "! You are " + age + " months old.";
console.log("Old way:", oldWay);

// New way (template literals)
let newWay = `Hello, ${name}! You are ${age} months old.`;
console.log("New way:", newWay);

// Multiline strings
let multiline = `
  This is a
  multiline string
  using template literals!
`;
console.log("Multiline:", multiline);

// Expression evaluation
let a = 10;
let b = 5;
console.log(`Sum: ${a + b}, Product: ${a * b}`);

console.log("\n=== 2. CLASSES ===");

// Class definition
class Person {
  // Constructor
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }

  // Method
  greet() {
    return `Hi, I'm ${this.name} and I'm ${this.age} years old!`;
  }

  // Method with parameters
  haveBirthday() {
    this.age++;
    return `Happy Birthday! Now I'm ${this.age} years old.`;
  }
}

// Create instances (objects) from class
let person1 = new Person("Alice", 25);
let person2 = new Person("Bob", 30);

console.log(person1.greet());
console.log(person2.greet());
console.log(person1.haveBirthday());

// Class with inheritance
class Student extends Person {
  constructor(name, age, grade) {
    super(name, age); // Call parent constructor
    this.grade = grade;
  }

  study() {
    return `${this.name} is studying hard!`;
  }

  // Override parent method
  greet() {
    return `${super.greet()} I'm in grade ${this.grade}.`;
  }
}

let student1 = new Student("Charlie", 18, 12);
console.log(student1.greet());
console.log(student1.study());

console.log("\n=== 3. ENHANCED OBJECT FEATURES ===");

// Shorthand properties
let firstName = "John";
let lastName = "Doe";

// Old way
let personOld = {
  firstName: firstName,
  lastName: lastName
};

// New way (shorthand)
let personNew = {
  firstName,
  lastName
};
console.log("Shorthand object:", personNew);

// Computed property names
let propName = "age";
let personDynamic = {
  name: "Jane",
  [propName]: 28, // Dynamic property name
  [`${propName}InMonths`]: 28 * 12
};
console.log("Dynamic properties:", personDynamic);

// Method shorthand
let calculator = {
  // Old way
  addOld: function(a, b) {
    return a + b;
  },
  // New way (shorthand)
  add(a, b) {
    return a + b;
  },
  subtract(a, b) {
    return a - b;
  },
  multiply(a, b) {
    return a * b;
  }
};

console.log("Calculator:", calculator.add(5, 3));
console.log("Calculator:", calculator.multiply(4, 7));
```

**Run:** `node day3-practice.js`

**✅ Checkpoint:** ES6+ features working? Great! Move on.

---

### Step 3: Learn Modules (import/export) (30-40 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/modules-intro
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules

**💻 Practice Exercise 2:**

**Create multiple files to practice modules:**

1. **Create `utils.js` file:**
```javascript
// utils.js - Utility functions

// Export individual functions
export function add(a, b) {
  return a + b;
}

export function subtract(a, b) {
  return a - b;
}

export function multiply(a, b) {
  return a * b;
}

// Export default
export default function greet(name) {
  return `Hello, ${name}!`;
}
```

2. **Create `person.js` file:**
```javascript
// person.js - Person class

export class Person {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }

  greet() {
    return `Hi, I'm ${this.name}!`;
  }
}

// Export a constant
export const DEFAULT_AGE = 18;
```

3. **Update `day3-practice.js` to import modules:**

**Note:** For Node.js, you need to use ES modules. Update your code:

```javascript
// day3-practice-modules.js
// IMPORTANT: For this to work, you need to either:
// 1. Add "type": "module" to package.json, OR
// 2. Use .mjs extension

console.log("=== MODULES PRACTICE ===");

// For now, let's use CommonJS format (Node.js default)
// We'll switch to ES modules when we use React Native

// Using require (CommonJS - Node.js way)
// This is just for practice - React Native uses ES6 modules

console.log("Note: Modules are used extensively in React Native");
console.log("You'll use import/export in your app code!");
```

**For React Native, you'll use ES6 modules like this:**

```javascript
// In React Native (future):
// import { add, subtract } from './utils';
// import Person from './person';
// import greet, { Person } from './modules';
```

**✅ Checkpoint:** Modules concept understood? Perfect! (Note: We'll use ES6 modules in React Native)

---

### Step 4: Learn Promises (40-50 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/promise-basics
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise

**Why Promises?**
- JavaScript is asynchronous (can do multiple things at once)
- Promises handle operations that take time (like API calls)
- Better than callbacks (avoids "callback hell")

**What to Learn:**

1. **Creating Promises:**
   ```javascript
   new Promise((resolve, reject) => {
     // async operation
     if (success) resolve(value);
     else reject(error);
   })
   ```

2. **Using Promises:**
   ```javascript
   promise
     .then(result => { /* handle success */ })
     .catch(error => { /* handle error */ })
   ```

3. **Promise.all()** - Wait for all promises
4. **Promise.race()** - Wait for first promise

**💻 Practice Exercise 3:**
Add this to your `day3-practice.js`:

```javascript
console.log("\n=== 4. PROMISES ===");

// Create a simple promise
function simulateAsyncTask(shouldSucceed = true) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (shouldSucceed) {
        resolve("Task completed successfully!");
      } else {
        reject("Task failed!");
      }
    }, 2000); // Wait 2 seconds
  });
}

// Using Promise with .then() and .catch()
console.log("Starting async task...");
simulateAsyncTask(true)
  .then(result => {
    console.log("Success:", result);
  })
  .catch(error => {
    console.log("Error:", error);
  });

// Promise that fails
simulateAsyncTask(false)
  .then(result => {
    console.log("Success:", result);
  })
  .catch(error => {
    console.log("Error:", error);
  });

// Real-world example: Fetching user data
function fetchUserData(userId) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (userId > 0) {
        resolve({
          id: userId,
          name: "John Doe",
          email: "john@example.com"
        });
      } else {
        reject("Invalid user ID");
      }
    }, 1000);
  });
}

// Using the promise
fetchUserData(1)
  .then(user => {
    console.log("User data:", user);
    return user.name; // Can chain promises
  })
  .then(name => {
    console.log("User name:", name);
  })
  .catch(error => {
    console.log("Failed to fetch user:", error);
  });

// Promise.all() - Wait for multiple promises
let promise1 = new Promise(resolve => setTimeout(() => resolve("Task 1 done"), 1000));
let promise2 = new Promise(resolve => setTimeout(() => resolve("Task 2 done"), 2000));
let promise3 = new Promise(resolve => setTimeout(() => resolve("Task 3 done"), 1500));

Promise.all([promise1, promise2, promise3])
  .then(results => {
    console.log("All tasks completed:", results);
  });

// Note: Run this code and observe the timing!
```

**Run:** `node day3-practice.js`  
**Note:** Watch the timing - promises complete asynchronously!

**✅ Checkpoint:** Promises understood? Excellent!

---

## ☕ BREAK TIME (15-30 minutes)

Take a break! Promises can be tricky at first. Come back refreshed for Async/Await!

---

## ✅ AFTERNOON SESSION (2-3 hours)

### Step 5: Learn Async/Await (50-60 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/async-await
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function

**Why Async/Await?**
- Modern way to handle Promises
- Makes async code look like sync code
- Easier to read and write
- Use `async` functions and `await` keyword

**What to Learn:**

1. **async function:**
   ```javascript
   async function myFunction() {
     // This function returns a Promise
   }
   ```

2. **await keyword:**
   ```javascript
   async function myFunction() {
     let result = await somePromise();
     // Waits for promise to resolve
   }
   ```

3. **Error handling with try/catch**

**💻 Practice Exercise 4:**
Add this to your `day3-practice.js`:

```javascript
console.log("\n=== 5. ASYNC/AWAIT ===");

// Convert previous Promise example to async/await
async function fetchUserDataAsync(userId) {
  // Simulate delay
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  if (userId > 0) {
    return {
      id: userId,
      name: "Alice Smith",
      email: "alice@example.com",
      age: 28
    };
  } else {
    throw new Error("Invalid user ID");
  }
}

// Using async/await (much cleaner!)
async function displayUser(userId) {
  try {
    console.log("Fetching user...");
    let user = await fetchUserDataAsync(userId);
    console.log("User fetched:", user);
    console.log(`Name: ${user.name}, Email: ${user.email}`);
    return user;
  } catch (error) {
    console.log("Error fetching user:", error.message);
    return null;
  }
}

// Call the async function
displayUser(1);
displayUser(0); // This will fail

// Multiple async operations
async function fetchMultipleUsers() {
  try {
    console.log("\nFetching multiple users...");
    let user1 = await fetchUserDataAsync(1);
    let user2 = await fetchUserDataAsync(2);
    let user3 = await fetchUserDataAsync(3);
    
    console.log("All users:", [user1, user2, user3]);
  } catch (error) {
    console.log("Error:", error.message);
  }
}

// Using Promise.all with async/await
async function fetchAllUsersParallel() {
  try {
    console.log("\nFetching users in parallel...");
    let users = await Promise.all([
      fetchUserDataAsync(1),
      fetchUserDataAsync(2),
      fetchUserDataAsync(3)
    ]);
    console.log("All users (parallel):", users);
  } catch (error) {
    console.log("Error:", error.message);
  }
}

// Uncomment to test:
// fetchMultipleUsers();
// fetchAllUsersParallel();
```

**Note:** Uncomment the function calls at the end to test them!

**✅ Checkpoint:** Async/Await clear? Perfect! This is crucial for React Native!

---

### Step 6: Learn Error Handling (30-40 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/try-catch
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Control_flow_and_error_handling

**What to Learn:**

1. **try/catch/finally:**
   ```javascript
   try {
     // code that might fail
   } catch (error) {
     // handle error
   } finally {
     // always runs
   }
   ```

2. **Error types:**
   - `Error` - Generic error
   - `TypeError` - Wrong type
   - `ReferenceError` - Variable not found
   - Custom errors

**💻 Practice Exercise 5:**
Add this to your `day3-practice.js`:

```javascript
console.log("\n=== 6. ERROR HANDLING ===");

// Basic try/catch
function divideNumbers(a, b) {
  try {
    if (b === 0) {
      throw new Error("Cannot divide by zero!");
    }
    return a / b;
  } catch (error) {
    console.log("Error caught:", error.message);
    return null;
  }
}

console.log("10 / 2 =", divideNumbers(10, 2));
console.log("10 / 0 =", divideNumbers(10, 0));

// try/catch/finally
function processData(data) {
  try {
    console.log("Processing data:", data);
    if (!data) {
      throw new Error("No data provided");
    }
    let result = data.toUpperCase();
    return result;
  } catch (error) {
    console.log("Error:", error.message);
    return "DEFAULT_VALUE";
  } finally {
    console.log("Process completed (this always runs)");
  }
}

processData("hello");
processData(null);

// Error handling with async/await
async function safeAsyncOperation() {
  try {
    let result = await fetchUserDataAsync(1);
    console.log("Operation successful:", result);
  } catch (error) {
    console.log("Operation failed:", error.message);
  } finally {
    console.log("Async operation finished");
  }
}

safeAsyncOperation();

// Different error types
try {
  let undefinedVar = someUndefinedVariable; // ReferenceError
} catch (error) {
  console.log("Error type:", error.name);
  console.log("Error message:", error.message);
}

try {
  null.someMethod(); // TypeError
} catch (error) {
  console.log("Error type:", error.name);
}

// Custom error
class ValidationError extends Error {
  constructor(message) {
    super(message);
    this.name = "ValidationError";
  }
}

function validateAge(age) {
  try {
    if (age < 0) {
      throw new ValidationError("Age cannot be negative");
    }
    if (age > 120) {
      throw new ValidationError("Age seems invalid");
    }
    return true;
  } catch (error) {
    if (error instanceof ValidationError) {
      console.log("Validation error:", error.message);
    } else {
      console.log("Unknown error:", error.message);
    }
    return false;
  }
}

validateAge(25);
validateAge(-5);
validateAge(150);
```

**Run:** `node day3-practice.js`

**✅ Checkpoint:** Error handling clear? Great!

---

### Step 7: Learn Fetch API and JSON (50-60 minutes)

**📖 Learning Resources:**
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API
- **JavaScript.info:** https://javascript.info/fetch

**Why Fetch API?**
- Used to make HTTP requests (get data from APIs)
- Essential for React Native apps
- Works with Promises/Async-Await

**What to Learn:**

1. **Fetch basics:**
   ```javascript
   fetch(url)
     .then(response => response.json())
     .then(data => console.log(data))
   ```

2. **Fetch with async/await:**
   ```javascript
   async function getData() {
     let response = await fetch(url);
     let data = await response.json();
   }
   ```

3. **JSON manipulation:**
   - `JSON.stringify()` - Convert object to JSON string
   - `JSON.parse()` - Convert JSON string to object

**💻 Practice Exercise 6:**
Add this to your `day3-practice.js`:

```javascript
console.log("\n=== 7. FETCH API AND JSON ===");

// Note: Fetch API works in browsers and React Native
// For Node.js, you'll need to install node-fetch or use axios

// First, let's practice JSON
let person = {
  name: "John Doe",
  age: 30,
  city: "New York",
  hobbies: ["reading", "coding", "traveling"]
};

// Convert object to JSON string
let jsonString = JSON.stringify(person);
console.log("JSON String:", jsonString);
console.log("Type:", typeof jsonString);

// Convert JSON string back to object
let parsedObject = JSON.parse(jsonString);
console.log("Parsed Object:", parsedObject);
console.log("Type:", typeof parsedObject);

// Real-world example: Storing in localStorage (browser)
// localStorage.setItem('user', jsonString);
// let stored = localStorage.getItem('user');
// let user = JSON.parse(stored);

// Fetch API example (works in browser/React Native)
// For Node.js, install: npm install node-fetch

// Example: Fetch from a public API
async function fetchData() {
  try {
    console.log("Fetching data from API...");
    
    // Using a free public API for practice
    let response = await fetch('https://jsonplaceholder.typicode.com/users/1');
    
    // Check if response is OK
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    // Parse JSON response
    let data = await response.json();
    
    console.log("User data:", data);
    console.log("Name:", data.name);
    console.log("Email:", data.email);
    
    return data;
  } catch (error) {
    console.log("Error fetching data:", error.message);
    return null;
  }
}

// Uncomment to test (requires internet connection):
// fetchData();

// Fetch multiple endpoints
async function fetchMultipleEndpoints() {
  try {
    let [users, posts] = await Promise.all([
      fetch('https://jsonplaceholder.typicode.com/users').then(r => r.json()),
      fetch('https://jsonplaceholder.typicode.com/posts').then(r => r.json())
    ]);
    
    console.log("Users count:", users.length);
    console.log("Posts count:", posts.length);
  } catch (error) {
    console.log("Error:", error.message);
  }
}

// POST request example (creating data)
async function createPost() {
  try {
    let response = await fetch('https://jsonplaceholder.typicode.com/posts', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        title: 'My New Post',
        body: 'This is the content of my post',
        userId: 1
      })
    });
    
    let newPost = await response.json();
    console.log("Created post:", newPost);
    return newPost;
  } catch (error) {
    console.log("Error creating post:", error.message);
  }
}

// Uncomment to test:
// createPost();
```

**Important Notes:**
- Fetch API works in browsers and React Native
- For Node.js (terminal), you'll need `node-fetch` package
- The examples above will work when you use them in React Native!

**✅ Checkpoint:** Fetch and JSON understood? Excellent!

---

### Step 8: Build a Real Project - Weather App (40-50 minutes)

**💻 Challenge: Build a Simple Weather App using an API**

Create a new file: `weather-app.js`

```javascript
// weather-app.js
// Simple Weather App using OpenWeatherMap API

// Note: You'll need a free API key from https://openweathermap.org/api
// For now, this is just the structure

async function getWeather(city) {
  try {
    // In real app, you'd use your API key
    // const API_KEY = 'your_api_key_here';
    // const url = `https://api.openweathermap.org/data/2.5/weather?q=${city}&appid=${API_KEY}`;
    
    // For practice, using a mock API
    console.log(`Fetching weather for ${city}...`);
    
    // Simulate API call
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Mock weather data
    let weatherData = {
      city: city,
      temperature: Math.floor(Math.random() * 30) + 10, // 10-40°C
      condition: ["Sunny", "Cloudy", "Rainy", "Snowy"][Math.floor(Math.random() * 4)],
      humidity: Math.floor(Math.random() * 40) + 40,
      windSpeed: Math.floor(Math.random() * 20) + 5
    };
    
    return weatherData;
  } catch (error) {
    throw new Error(`Failed to fetch weather: ${error.message}`);
  }
}

async function displayWeather(city) {
  try {
    let weather = await getWeather(city);
    
    console.log("\n=== WEATHER REPORT ===");
    console.log(`City: ${weather.city}`);
    console.log(`Temperature: ${weather.temperature}°C`);
    console.log(`Condition: ${weather.condition}`);
    console.log(`Humidity: ${weather.humidity}%`);
    console.log(`Wind Speed: ${weather.windSpeed} km/h`);
    console.log("====================\n");
    
    return weather;
  } catch (error) {
    console.log("Error:", error.message);
    return null;
  }
}

// Test the weather app
async function main() {
  await displayWeather("London");
  await displayWeather("New York");
  await displayWeather("Tokyo");
  
  // Fetch multiple cities in parallel
  console.log("Fetching multiple cities...");
  let cities = ["Paris", "Berlin", "Madrid"];
  let weatherReports = await Promise.all(
    cities.map(city => getWeather(city))
  );
  
  console.log("\n=== ALL WEATHER REPORTS ===");
  weatherReports.forEach(weather => {
    console.log(`${weather.city}: ${weather.temperature}°C, ${weather.condition}`);
  });
}

// Run the app
main();
```

**Run:** `node weather-app.js`

**✅ Challenge:** Try modifying this to:
- Add error handling for invalid cities
- Format the output better
- Add more weather details
- Create a function to compare weather in multiple cities

---

### Step 9: Review and Consolidate (20-30 minutes)

1. **Review your code:**
   - Go through all exercises
   - Make sure you understand Promises vs Async/Await
   - Understand error handling
   - Review Fetch API and JSON

2. **Key Concepts Quiz (test yourself):**
   - What's the difference between Promises and Async/Await?
   - When do you use try/catch?
   - How do you convert an object to JSON?
   - What does `await` do?
   - How do you handle errors in async functions?

3. **Create a summary:**
   - Update `day2-summary.md` or create `day3-summary.md`
   - Write down key concepts
   - Add code examples

---

## 🎉 CONGRATULATIONS! Day 3 Complete!

You've learned:
- ✅ ES6+ advanced features (Template literals, Classes)
- ✅ Promises (handling asynchronous operations)
- ✅ Async/Await (modern async code)
- ✅ Error Handling (try/catch/finally)
- ✅ Fetch API (making HTTP requests)
- ✅ JSON manipulation (stringify/parse)
- ✅ Built a simple weather app!

---

## 📝 What's Next?

**Tomorrow (Day 4):** You'll start learning React!
- React fundamentals
- Components
- Props
- State
- JSX syntax

**For now:**
- ✅ Review today's concepts
- ✅ Make sure you understand Promises and Async/Await (very important!)
- ✅ Complete the weather app challenge
- ✅ Take a break - you've learned a lot!

---

## 🆘 Troubleshooting

### Promises not working?
- Make sure you understand the concept first
- Try writing simple promises before complex ones
- Use async/await - it's easier!

### Fetch API not working in Node.js?
- That's normal! Fetch works in browsers and React Native
- For Node.js practice, install: `npm install node-fetch`
- In React Native, fetch works natively!

### Async/Await confusing?
- Remember: `async` function = returns a Promise
- `await` = wait for Promise to resolve
- Always use `try/catch` with async/await

### Need more practice?
- **JavaScript.info:** https://javascript.info/async (great exercises)
- **MDN:** Practice with their examples
- **FreeCodeCamp:** Async JavaScript section

---

## 📚 Additional Resources

**Free Learning Platforms:**
- **JavaScript.info** - https://javascript.info/async
- **MDN Web Docs** - https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function
- **FreeCodeCamp** - Async JavaScript course section
- **YouTube:** Search "JavaScript Promises Async Await tutorial"

**Practice APIs (for Fetch practice):**
- **JSONPlaceholder** - https://jsonplaceholder.typicode.com/ (fake REST API)
- **OpenWeatherMap** - https://openweathermap.org/api (weather - free tier)
- **Dog API** - https://dog.ceo/dog-api/ (random dog images)
- **Cat API** - https://thecatapi.com/ (random cat images)

---

## 💡 Important Notes for React Native

**What you learned today is crucial for React Native:**

1. **Async/Await** - You'll use this constantly for:
   - API calls
   - Database operations
   - File operations
   - Navigation

2. **Fetch API** - Used for:
   - Getting data from your backend
   - Sending data to your backend
   - Integrating with third-party APIs

3. **Error Handling** - Essential for:
   - Handling network errors
   - Validating user input
   - Debugging issues

4. **JSON** - Used for:
   - API responses
   - Storing data
   - Passing data between components

**Remember:** Everything you learned today will be used extensively in React Native!

---

**Great job completing Day 3! You now have advanced JavaScript knowledge! 🚀**

**Tomorrow: React fundamentals - you're getting closer to building your app!**
