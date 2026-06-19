# 📚 DAY 2 - Your Action Plan: JavaScript Basics

**Time Required:** 4-6 hours  
**Goal:** Learn JavaScript fundamentals - the foundation of React Native development

---

## 🎯 Today's Learning Objectives

By the end of today, you will understand:
- ✅ Variables and data types
- ✅ Operators (arithmetic, comparison, logical)
- ✅ Conditional statements (if/else, switch)
- ✅ Loops (for, while, forEach, map, filter)
- ✅ Functions (declarations, expressions, arrow functions)
- ✅ Arrays and Objects
- ✅ Destructuring and Spread operator

---

## ✅ MORNING SESSION (2-3 hours)

### Step 1: Set Up Your Learning Environment (10 minutes)

1. **Create a new folder for practice:**
   - Open PowerShell
   - Navigate to your Desktop:
     ```powershell
     cd Desktop
     ```
   - Create a folder:
     ```powershell
     mkdir JavaScript-Practice
     cd JavaScript-Practice
     ```

2. **Open VS Code in this folder:**
   ```powershell
     code .
     ```
   - This opens VS Code in your practice folder

3. **Create your first JavaScript file:**
   - In VS Code, click "New File" or press `Ctrl+N`
   - Save it as `day2-practice.js` (File → Save As)
   - You'll write all your practice code here!

---

### Step 2: Learn Variables and Data Types (30-40 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/variables (read sections 2.1-2.4)
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Grammar_and_types#declarations

**What to Learn:**

1. **Variables:**
   - `let` - for variables that can change
   - `const` - for constants (cannot change)
   - `var` - old way (avoid using this)

2. **Data Types:**
   - Numbers: `42`, `3.14`
   - Strings: `"Hello"`, `'World'`
   - Booleans: `true`, `false`
   - Undefined: `undefined`
   - Null: `null`

**💻 Practice Exercise 1:**
Type this code in your `day2-practice.js` file:

```javascript
// Variables and Data Types Practice

// 1. Create variables with different data types
let myName = "Your Name";
const myAge = 25;
let isStudent = true;
let favoriteColor = null;

// 2. Print them to console
console.log("Name:", myName);
console.log("Age:", myAge);
console.log("Is Student:", isStudent);
console.log("Favorite Color:", favoriteColor);

// 3. Try changing a const (this will cause an error - that's expected!)
// Uncomment the line below to see the error:
// myAge = 26; // This will show an error because const cannot be changed
```

**Run your code:**
- Open PowerShell in your folder
- Run: `node day2-practice.js`
- You should see the output!

**✅ Checkpoint:** Can you create variables? Great! Move on.

---

### Step 3: Learn Operators (30-40 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/operators
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Expressions_and_Operators

**What to Learn:**

1. **Arithmetic Operators:**
   - `+` (addition)
   - `-` (subtraction)
   - `*` (multiplication)
   - `/` (division)
   - `%` (modulus - remainder)
   - `**` (exponentiation)

2. **Comparison Operators:**
   - `==` (equal to - loose)
   - `===` (equal to - strict, preferred!)
   - `!=` (not equal)
   - `!==` (not equal - strict)
   - `>` (greater than)
   - `<` (less than)
   - `>=` (greater than or equal)
   - `<=` (less than or equal)

3. **Logical Operators:**
   - `&&` (AND)
   - `||` (OR)
   - `!` (NOT)

**💻 Practice Exercise 2:**
Add this to your file:

```javascript
// Operators Practice

// Arithmetic
let num1 = 10;
let num2 = 5;

console.log("Addition:", num1 + num2);        // 15
console.log("Subtraction:", num1 - num2);     // 5
console.log("Multiplication:", num1 * num2);  // 50
console.log("Division:", num1 / num2);        // 2
console.log("Modulus:", num1 % num2);         // 0
console.log("Exponentiation:", num1 ** num2); // 100000

// Comparison
console.log("Is equal?", num1 === num2);      // false
console.log("Is greater?", num1 > num2);     // true
console.log("Is less or equal?", num1 <= num2); // false

// Logical
let isAdult = true;
let hasLicense = false;

console.log("Can drive?", isAdult && hasLicense);  // false
console.log("Is adult or has license?", isAdult || hasLicense); // true
console.log("Is not adult?", !isAdult);            // false
```

**Run:** `node day2-practice.js`

**✅ Checkpoint:** Operators working? Excellent!

---

### Step 4: Learn Conditional Statements (40-50 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/ifelse
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Control_flow_and_error_handling

**What to Learn:**

1. **if/else statements:**
   ```javascript
   if (condition) {
     // code to run if true
   } else {
     // code to run if false
   }
   ```

2. **else if:**
   ```javascript
   if (condition1) {
     // code
   } else if (condition2) {
     // code
   } else {
     // code
   }
   ```

3. **Ternary operator:**
   ```javascript
   condition ? valueIfTrue : valueIfFalse
   ```

4. **Switch statement:**
   ```javascript
   switch (value) {
     case 'option1':
       // code
       break;
     case 'option2':
       // code
       break;
     default:
       // code
   }
   ```

**💻 Practice Exercise 3:**
Add this to your file:

```javascript
// Conditional Statements Practice

// 1. Simple if/else
let age = 20;

if (age >= 18) {
  console.log("You are an adult");
} else {
  console.log("You are a minor");
}

// 2. else if
let score = 85;

if (score >= 90) {
  console.log("Grade: A");
} else if (score >= 80) {
  console.log("Grade: B");
} else if (score >= 70) {
  console.log("Grade: C");
} else {
  console.log("Grade: F");
}

// 3. Ternary operator
let isMember = true;
let discount = isMember ? 0.1 : 0; // 10% discount if member
console.log("Discount:", discount);

// 4. Switch statement
let day = "Monday";

switch (day) {
  case "Monday":
    console.log("Start of work week");
    break;
  case "Friday":
    console.log("TGIF!");
    break;
  case "Saturday":
  case "Sunday":
    console.log("Weekend!");
    break;
  default:
    console.log("Midweek");
}
```

**Run:** `node day2-practice.js`

**✅ Checkpoint:** Conditionals understood? Perfect!

---

### Step 5: Learn Loops (40-50 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/while-for
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Loops_and_iteration

**What to Learn:**

1. **for loop:**
   ```javascript
   for (let i = 0; i < 10; i++) {
     // code
   }
   ```

2. **while loop:**
   ```javascript
   while (condition) {
     // code
   }
   ```

3. **Array methods:**
   - `forEach()` - loop through array
   - `map()` - transform array elements
   - `filter()` - filter array elements

**💻 Practice Exercise 4:**
Add this to your file:

```javascript
// Loops Practice

// 1. for loop
console.log("Counting 1 to 5:");
for (let i = 1; i <= 5; i++) {
  console.log(i);
}

// 2. while loop
console.log("\nCounting down from 5:");
let count = 5;
while (count > 0) {
  console.log(count);
  count--; // decrease by 1
}

// 3. Arrays
let fruits = ["apple", "banana", "orange", "grape"];

// forEach - just loop through
console.log("\nAll fruits:");
fruits.forEach(function(fruit) {
  console.log(fruit);
});

// map - transform each element
console.log("\nFruits in uppercase:");
let upperFruits = fruits.map(function(fruit) {
  return fruit.toUpperCase();
});
console.log(upperFruits);

// filter - get only certain elements
console.log("\nFruits with 'a':");
let fruitsWithA = fruits.filter(function(fruit) {
  return fruit.includes('a');
});
console.log(fruitsWithA);
```

**Run:** `node day2-practice.js`

**✅ Checkpoint:** Loops working? Awesome!

---

## ☕ BREAK TIME (15-30 minutes)

Take a break! You've learned a lot. Stretch, grab a snack, and come back refreshed.

---

## ✅ AFTERNOON SESSION (2-3 hours)

### Step 6: Learn Functions (50-60 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** https://javascript.info/function-basics
- **MDN Docs:** https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Functions

**What to Learn:**

1. **Function Declaration:**
   ```javascript
   function functionName(parameters) {
     // code
     return value;
   }
   ```

2. **Function Expression:**
   ```javascript
   const functionName = function(parameters) {
     // code
   };
   ```

3. **Arrow Functions (Modern JavaScript):**
   ```javascript
   const functionName = (parameters) => {
     // code
   };
   
   // Short form (single expression):
   const add = (a, b) => a + b;
   ```

4. **Function Parameters:**
   - Required parameters
   - Default parameters
   - Rest parameters (`...args`)

**💻 Practice Exercise 5:**
Add this to your file:

```javascript
// Functions Practice

// 1. Function Declaration
function greet(name) {
  return "Hello, " + name + "!";
}
console.log(greet("VIRTUOMATE"));

// 2. Function Expression
const multiply = function(a, b) {
  return a * b;
};
console.log("5 * 3 =", multiply(5, 3));

// 3. Arrow Function
const subtract = (a, b) => {
  return a - b;
};
console.log("10 - 4 =", subtract(10, 4));

// 4. Arrow Function (short form)
const divide = (a, b) => a / b;
console.log("20 / 4 =", divide(20, 4));

// 5. Default Parameters
function introduce(name = "Guest", age = 0) {
  return `Hi, I'm ${name} and I'm ${age} years old`;
}
console.log(introduce("Alice", 25));
console.log(introduce()); // Uses defaults

// 6. Rest Parameters
function sum(...numbers) {
  let total = 0;
  for (let num of numbers) {
    total += num;
  }
  return total;
}
console.log("Sum:", sum(1, 2, 3, 4, 5)); // 15
```

**Run:** `node day2-practice.js`

**✅ Checkpoint:** Functions clear? Great!

---

### Step 7: Learn Arrays and Objects (50-60 minutes)

**📖 Learning Resources:**
- **JavaScript.info:** 
  - Arrays: https://javascript.info/array
  - Objects: https://javascript.info/object
- **MDN Docs:**
  - Arrays: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array
  - Objects: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Working_with_Objects

**What to Learn:**

1. **Arrays:**
   - Creating arrays
   - Accessing elements (`array[0]`)
   - Array methods: `push()`, `pop()`, `shift()`, `unshift()`, `length`
   - Array methods: `map()`, `filter()`, `find()`, `includes()`

2. **Objects:**
   - Creating objects
   - Accessing properties (`object.property` or `object['property']`)
   - Adding/modifying properties
   - Object methods

3. **Destructuring:**
   ```javascript
   // Array destructuring
   const [first, second] = array;
   
   // Object destructuring
   const {name, age} = person;
   ```

4. **Spread Operator:**
   ```javascript
   const newArray = [...oldArray];
   const newObject = {...oldObject};
   ```

**💻 Practice Exercise 6:**
Add this to your file:

```javascript
// Arrays and Objects Practice

// 1. Arrays
let colors = ["red", "green", "blue"];
console.log("First color:", colors[0]); // red
console.log("Array length:", colors.length); // 3

// Add to end
colors.push("yellow");
console.log("After push:", colors);

// Remove from end
colors.pop();
console.log("After pop:", colors);

// Array methods
let numbers = [1, 2, 3, 4, 5];

// map - double each number
let doubled = numbers.map(num => num * 2);
console.log("Doubled:", doubled); // [2, 4, 6, 8, 10]

// filter - get even numbers
let evens = numbers.filter(num => num % 2 === 0);
console.log("Even numbers:", evens); // [2, 4]

// find - find first number > 3
let found = numbers.find(num => num > 3);
console.log("First > 3:", found); // 4

// includes - check if exists
console.log("Has 3?", numbers.includes(3)); // true

// 2. Objects
let person = {
  name: "John",
  age: 30,
  city: "New York",
  isStudent: false
};

console.log("Person name:", person.name);
console.log("Person age:", person.age);
console.log("Person city:", person["city"]);

// Add property
person.email = "john@example.com";
console.log("Person:", person);

// Object with method
let calculator = {
  add: function(a, b) {
    return a + b;
  },
  subtract(a, b) { // shorthand method
    return a - b;
  }
};

console.log("5 + 3 =", calculator.add(5, 3));
console.log("10 - 4 =", calculator.subtract(10, 4));

// 3. Destructuring
// Array destructuring
let fruits = ["apple", "banana", "orange"];
let [first, second] = fruits;
console.log("First:", first); // apple
console.log("Second:", second); // banana

// Object destructuring
let {name, age} = person;
console.log("Name:", name);
console.log("Age:", age);

// 4. Spread Operator
// Array spread
let arr1 = [1, 2, 3];
let arr2 = [4, 5, 6];
let combined = [...arr1, ...arr2];
console.log("Combined:", combined); // [1, 2, 3, 4, 5, 6]

// Object spread
let person1 = {name: "Alice", age: 25};
let person2 = {...person1, city: "Boston"};
console.log("Person2:", person2); // {name: "Alice", age: 25, city: "Boston"}
```

**Run:** `node day2-practice.js`

**✅ Checkpoint:** Arrays and Objects understood? Perfect!

---

### Step 8: Practice Exercises (30-40 minutes)

**💻 Challenge Exercises:**

Create a new file called `day2-challenges.js` and solve these:

**Challenge 1: Calculator Function**
```javascript
// Create a function that takes two numbers and an operator (+, -, *, /)
// and returns the result
// Example: calculate(10, 5, '+') should return 15

function calculate(a, b, operator) {
  // Your code here
}

console.log(calculate(10, 5, '+')); // Should print 15
console.log(calculate(10, 5, '-')); // Should print 5
console.log(calculate(10, 5, '*')); // Should print 50
console.log(calculate(10, 5, '/')); // Should print 2
```

**Challenge 2: Find Largest Number**
```javascript
// Create a function that takes an array of numbers
// and returns the largest number
// Example: findLargest([3, 7, 2, 9, 1]) should return 9

function findLargest(numbers) {
  // Your code here
}

console.log(findLargest([3, 7, 2, 9, 1])); // Should print 9
```

**Challenge 3: Filter Students**
```javascript
// Create a function that filters students by age
// Return only students who are 18 or older
// Example: filterAdults([{name: "Alice", age: 20}, {name: "Bob", age: 17}])
// should return [{name: "Alice", age: 20}]

function filterAdults(students) {
  // Your code here
}

let students = [
  {name: "Alice", age: 20},
  {name: "Bob", age: 17},
  {name: "Charlie", age: 19}
];

console.log(filterAdults(students));
```

**Challenge 4: Count Vowels**
```javascript
// Create a function that counts vowels in a string
// Example: countVowels("Hello") should return 2

function countVowels(str) {
  // Your code here
}

console.log(countVowels("Hello")); // Should print 2
console.log(countVowels("VIRTUOMATE")); // Should print 5
```

**Try to solve these yourself!** If you get stuck, that's okay - you can look at solutions online or ask for help.

---

### Step 9: Review and Consolidate (20-30 minutes)

1. **Review your code:**
   - Go through all the exercises you wrote today
   - Make sure you understand each concept
   - Try modifying the code to see what happens

2. **Test your understanding:**
   - Can you explain what `let`, `const`, and `var` do?
   - Can you write an if/else statement?
   - Can you create a function?
   - Can you work with arrays and objects?

3. **Create a summary:**
   - Create a file called `day2-summary.md`
   - Write down the key concepts you learned
   - Write examples of each concept

---

## 🎉 CONGRATULATIONS! Day 2 Complete!

You've learned:
- ✅ Variables and data types
- ✅ Operators
- ✅ Conditional statements
- ✅ Loops
- ✅ Functions
- ✅ Arrays and Objects
- ✅ Destructuring and Spread operator

---

## 📝 What's Next?

**Tomorrow (Day 3):** You'll learn advanced JavaScript concepts:
- ES6+ features
- Promises and Async/Await
- Error handling
- Fetch API
- JSON manipulation

**For now:**
- ✅ Review what you learned today
- ✅ Complete the challenge exercises
- ✅ Make sure you understand everything before moving on
- ✅ Take a break - you've earned it!

---

## 🆘 Troubleshooting

### Code not running?
- Make sure you saved the file (`.js` extension)
- Check for typos in your code
- Make sure you're in the right folder in PowerShell
- Use `node filename.js` to run

### Don't understand something?
- Re-read the learning resources
- Try the code yourself and experiment
- Search on MDN or JavaScript.info
- It's okay to not understand everything immediately - keep practicing!

### Need more practice?
- Visit: https://www.freecodecamp.org/learn/javascript-algorithms-and-data-structures/
- Visit: https://javascript.info/ (interactive exercises)
- Try: https://www.codewars.com/ (coding challenges)

---

## 📚 Additional Resources

**Free Learning Platforms:**
- **JavaScript.info** - https://javascript.info/ (excellent interactive tutorial)
- **MDN Web Docs** - https://developer.mozilla.org/en-US/docs/Web/JavaScript (comprehensive reference)
- **FreeCodeCamp** - https://www.freecodecamp.org/learn/javascript-algorithms-and-data-structures/ (free course)
- **W3Schools** - https://www.w3schools.com/js/ (simple explanations)

**Practice Platforms:**
- **Codecademy** - JavaScript course (free tier available)
- **Codewars** - Coding challenges
- **LeetCode** - Algorithm practice

---

**Great job completing Day 2! You're building a solid foundation! 🚀**

**Remember:** Understanding JavaScript is crucial for React Native. Take your time, practice, and don't rush!
