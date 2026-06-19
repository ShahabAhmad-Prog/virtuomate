# ⚛️ DAY 4 - Your Action Plan: React Fundamentals Part 1

**Time Required:** 4-6 hours  
**Goal:** Learn React basics - Components, JSX, Props, State, and Event Handling

---

## 🎯 Today's Learning Objectives

By the end of today, you will understand:
- ✅ What React is and why we use it
- ✅ JSX syntax (JavaScript XML)
- ✅ Components (functional components)
- ✅ Props (passing data to components)
- ✅ State (useState hook)
- ✅ Event Handling
- ✅ Conditional Rendering
- ✅ Lists and Keys

---

## ✅ MORNING SESSION (2-3 hours)

### Step 1: Set Up React Environment (20-30 minutes)

**📖 Learning Resources:**
- **React Official Docs:** https://react.dev/learn
- **Create React App:** https://create-react-app.dev/

**What is React?**
- React is a JavaScript library for building user interfaces
- Created by Facebook (now Meta)
- Used for building web applications
- React Native (which we'll learn later) is based on React concepts
- Learning React first makes React Native much easier!

**💻 Set Up Your First React App:**

1. **Create a new React app:**
   ```powershell
   cd Desktop
   npx create-react-app my-first-react-app
   cd my-first-react-app
   ```

2. **Start the development server:**
   ```powershell
   npm start
   ```
   - This will open your browser automatically
   - You should see a spinning React logo
   - Keep this terminal open - it's running your app!

3. **Open the project in VS Code:**
   ```powershell
   code .
   ```

4. **Explore the project structure:**
   ```
   my-first-react-app/
   ├── public/
   │   └── index.html
   ├── src/
   │   ├── App.js          ← Main component
   │   ├── App.css
   │   ├── index.js        ← Entry point
   │   └── ...
   ├── package.json
   └── ...
   ```

5. **Open `src/App.js`** - This is your main component!

**✅ Checkpoint:** React app running? Great! Let's learn React!

---

### Step 2: Learn JSX Syntax (30-40 minutes)

**📖 Learning Resources:**
- **React Docs:** https://react.dev/learn/writing-markup-with-jsx
- **JavaScript.info:** React section

**What is JSX?**
- JSX = JavaScript XML
- Looks like HTML but it's JavaScript
- Allows you to write HTML-like code in JavaScript
- Must be compiled to regular JavaScript

**Key JSX Rules:**
1. Return single element (or use Fragment `<>...</>`)
2. Use `className` instead of `class`
3. Use `{}` for JavaScript expressions
4. Self-closing tags need `/` (e.g., `<img />`)
5. Use camelCase for attributes (`onClick`, not `onclick`)

**💻 Practice Exercise 1:**

Replace the content of `src/App.js` with this:

```javascript
// App.js
import './App.css';

function App() {
  // JSX allows us to write HTML-like code
  return (
    <div className="App">
      <h1>Hello, VIRTUOMATE!</h1>
      <p>This is my first React component!</p>
      
      {/* This is a comment in JSX */}
      
      {/* Using JavaScript expressions with {} */}
      <p>2 + 2 = {2 + 2}</p>
      
      {/* Variables */}
      {const name = "VIRTUOMATE";
      const age = 3;
      return (
        <div>
          <p>Name: {name}</p>
          <p>Age: {age} months</p>
        </div>
      );
      }
      
      {/* Actually, let's do it correctly: */}
      {(() => {
        const name = "VIRTUOMATE";
        const age = 3;
        return (
          <div>
            <p>Name: {name}</p>
            <p>Age: {age} months</p>
          </div>
        );
      })()}
      
      {/* Better way - define outside return */}
      {/* Let's fix this properly */}
    </div>
  );
}

export default App;
```

**Actually, let's do it the right way:**

```javascript
// App.js - Corrected version
import './App.css';

function App() {
  // Define variables before return
  const name = "VIRTUOMATE";
  const age = 3;
  const isActive = true;
  
  return (
    <div className="App">
      <h1>Hello, {name}!</h1>
      <p>This is my first React component!</p>
      
      {/* JavaScript expressions */}
      <p>2 + 2 = {2 + 2}</p>
      <p>Name: {name}</p>
      <p>Age: {age} months</p>
      
      {/* Conditional rendering */}
      {isActive && <p>Status: Active</p>}
      
      {/* Inline styles (object) */}
      <p style={{ color: 'blue', fontSize: '20px' }}>
        Styled text
      </p>
      
      {/* Multiple elements need wrapper or Fragment */}
      <>
        <h2>Fragment Example</h2>
        <p>No extra div wrapper!</p>
      </>
    </div>
  );
}

export default App;
```

**Save and check your browser** - it should update automatically!

**✅ Checkpoint:** JSX working? Perfect! Move on.

---

### Step 3: Learn Components (40-50 minutes)

**📖 Learning Resources:**
- **React Docs:** https://react.dev/learn/your-first-component
- **React Docs:** https://react.dev/learn/passing-props-to-a-component

**What are Components?**
- Components are reusable pieces of UI
- Like functions that return JSX
- Can be used multiple times
- Make code organized and reusable

**Types of Components:**
1. **Functional Components** (modern, recommended)
2. **Class Components** (older, we won't use these)

**💻 Practice Exercise 2:**

1. **Create a new component file:** `src/Header.js`

```javascript
// Header.js
function Header() {
  return (
    <header>
      <h1>VIRTUOMATE App</h1>
      <p>Welcome to your learning journey!</p>
    </header>
  );
}

export default Header;
```

2. **Create another component:** `src/UserCard.js`

```javascript
// UserCard.js
function UserCard() {
  return (
    <div style={{
      border: '1px solid #ccc',
      padding: '20px',
      margin: '10px',
      borderRadius: '8px',
      maxWidth: '300px'
    }}>
      <h3>User Profile</h3>
      <p>Name: John Doe</p>
      <p>Email: john@example.com</p>
      <button>View Profile</button>
    </div>
  );
}

export default UserCard;
```

3. **Update `App.js` to use components:**

```javascript
// App.js
import './App.css';
import Header from './Header';
import UserCard from './UserCard';

function App() {
  return (
    <div className="App">
      <Header />
      <h2>User Cards</h2>
      <UserCard />
      <UserCard />
      <UserCard />
    </div>
  );
}

export default App;
```

**Save and check browser** - you should see multiple user cards!

**✅ Checkpoint:** Components working? Excellent!

---

### Step 4: Learn Props (40-50 minutes)

**📖 Learning Resources:**
- **React Docs:** https://react.dev/learn/passing-props-to-a-component

**What are Props?**
- Props = Properties
- Way to pass data from parent to child component
- Read-only (cannot be changed by child)
- Make components reusable with different data

**💻 Practice Exercise 3:**

1. **Update `UserCard.js` to accept props:**

```javascript
// UserCard.js
function UserCard(props) {
  return (
    <div style={{
      border: '1px solid #ccc',
      padding: '20px',
      margin: '10px',
      borderRadius: '8px',
      maxWidth: '300px',
      backgroundColor: '#f9f9f9'
    }}>
      <h3>{props.name || 'User Profile'}</h3>
      <p>Email: {props.email}</p>
      <p>Age: {props.age}</p>
      {props.isActive && <p style={{ color: 'green' }}>✓ Active</p>}
      <button>View Profile</button>
    </div>
  );
}

export default UserCard;
```

**Or using destructuring (better way):**

```javascript
// UserCard.js - Improved with destructuring
function UserCard({ name, email, age, isActive }) {
  return (
    <div style={{
      border: '1px solid #ccc',
      padding: '20px',
      margin: '10px',
      borderRadius: '8px',
      maxWidth: '300px',
      backgroundColor: '#f9f9f9'
    }}>
      <h3>{name || 'User Profile'}</h3>
      <p>Email: {email}</p>
      <p>Age: {age}</p>
      {isActive && <p style={{ color: 'green' }}>✓ Active</p>}
      <button>View Profile</button>
    </div>
  );
}

export default UserCard;
```

2. **Update `App.js` to pass props:**

```javascript
// App.js
import './App.css';
import Header from './Header';
import UserCard from './UserCard';

function App() {
  return (
    <div className="App">
      <Header />
      <h2>User Cards</h2>
      
      <UserCard 
        name="Alice Smith"
        email="alice@example.com"
        age={25}
        isActive={true}
      />
      
      <UserCard 
        name="Bob Johnson"
        email="bob@example.com"
        age={30}
        isActive={false}
      />
      
      <UserCard 
        name="Charlie Brown"
        email="charlie@example.com"
        age={28}
        isActive={true}
      />
    </div>
  );
}

export default App;
```

**Save and check browser** - each card should show different data!

**✅ Checkpoint:** Props working? Great!

---

## ☕ BREAK TIME (15-30 minutes)

Take a break! You've learned a lot. Components and props are fundamental to React!

---

## ✅ AFTERNOON SESSION (2-3 hours)

### Step 5: Learn State with useState Hook (50-60 minutes)

**📖 Learning Resources:**
- **React Docs:** https://react.dev/learn/state-a-components-memory
- **React Docs:** https://react.dev/reference/react/useState

**What is State?**
- State = data that can change over time
- When state changes, component re-renders
- Each component can have its own state
- Use `useState` hook to manage state

**useState Hook:**
```javascript
const [state, setState] = useState(initialValue);
```

**💻 Practice Exercise 4:**

1. **Create a Counter component:** `src/Counter.js`

```javascript
// Counter.js
import { useState } from 'react';

function Counter() {
  // useState returns [currentValue, setterFunction]
  const [count, setCount] = useState(0);
  
  // Event handler functions
  const increment = () => {
    setCount(count + 1);
  };
  
  const decrement = () => {
    setCount(count - 1);
  };
  
  const reset = () => {
    setCount(0);
  };
  
  return (
    <div style={{
      padding: '20px',
      border: '2px solid #4CAF50',
      borderRadius: '8px',
      maxWidth: '300px',
      margin: '20px auto',
      textAlign: 'center'
    }}>
      <h2>Counter: {count}</h2>
      <button onClick={increment} style={{ margin: '5px', padding: '10px' }}>
        + Increment
      </button>
      <button onClick={decrement} style={{ margin: '5px', padding: '10px' }}>
        - Decrement
      </button>
      <button onClick={reset} style={{ margin: '5px', padding: '10px' }}>
        Reset
      </button>
    </div>
  );
}

export default Counter;
```

2. **Create a Todo List component:** `src/TodoList.js`

```javascript
// TodoList.js
import { useState } from 'react';

function TodoList() {
  const [todos, setTodos] = useState([]);
  const [inputValue, setInputValue] = useState('');
  
  const addTodo = () => {
    if (inputValue.trim() !== '') {
      setTodos([...todos, {
        id: Date.now(),
        text: inputValue,
        completed: false
      }]);
      setInputValue(''); // Clear input
    }
  };
  
  const toggleTodo = (id) => {
    setTodos(todos.map(todo =>
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    ));
  };
  
  const deleteTodo = (id) => {
    setTodos(todos.filter(todo => todo.id !== id));
  };
  
  return (
    <div style={{
      padding: '20px',
      maxWidth: '500px',
      margin: '20px auto',
      border: '1px solid #ddd',
      borderRadius: '8px'
    }}>
      <h2>Todo List</h2>
      
      {/* Input and Add button */}
      <div style={{ marginBottom: '20px' }}>
        <input
          type="text"
          value={inputValue}
          onChange={(e) => setInputValue(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && addTodo()}
          placeholder="Add a new todo..."
          style={{
            padding: '10px',
            width: '70%',
            marginRight: '10px',
            fontSize: '16px'
          }}
        />
        <button
          onClick={addTodo}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            backgroundColor: '#4CAF50',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Add
        </button>
      </div>
      
      {/* Todo list */}
      <ul style={{ listStyle: 'none', padding: 0 }}>
        {todos.map(todo => (
          <li
            key={todo.id}
            style={{
              padding: '10px',
              margin: '5px 0',
              backgroundColor: '#f5f5f5',
              borderRadius: '4px',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center'
            }}
          >
            <span
              onClick={() => toggleTodo(todo.id)}
              style={{
                textDecoration: todo.completed ? 'line-through' : 'none',
                color: todo.completed ? '#999' : '#000',
                cursor: 'pointer',
                flex: 1
              }}
            >
              {todo.text}
            </span>
            <button
              onClick={() => deleteTodo(todo.id)}
              style={{
                padding: '5px 10px',
                backgroundColor: '#f44336',
                color: 'white',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer'
              }}
            >
              Delete
            </button>
          </li>
        ))}
      </ul>
      
      {todos.length === 0 && (
        <p style={{ textAlign: 'center', color: '#999' }}>
          No todos yet. Add one above!
        </p>
      )}
    </div>
  );
}

export default TodoList;
```

3. **Update `App.js` to include new components:**

```javascript
// App.js
import './App.css';
import Header from './Header';
import UserCard from './UserCard';
import Counter from './Counter';
import TodoList from './TodoList';

function App() {
  return (
    <div className="App">
      <Header />
      
      <h2>User Cards</h2>
      <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'center' }}>
        <UserCard 
          name="Alice Smith"
          email="alice@example.com"
          age={25}
          isActive={true}
        />
        <UserCard 
          name="Bob Johnson"
          email="bob@example.com"
          age={30}
          isActive={false}
        />
      </div>
      
      <Counter />
      
      <TodoList />
    </div>
  );
}

export default App;
```

**Save and test:**
- Counter should increment/decrement
- Todo list should add/delete items
- Clicking todos should toggle completion

**✅ Checkpoint:** State working? Excellent! This is crucial!

---

### Step 6: Learn Event Handling (30-40 minutes)

**📖 Learning Resources:**
- **React Docs:** https://react.dev/learn/responding-to-events

**What are Events?**
- User interactions (clicks, typing, etc.)
- React uses `onClick`, `onChange`, `onSubmit`, etc.
- Event handlers are functions
- Use arrow functions or bind methods

**Common Events:**
- `onClick` - button clicks
- `onChange` - input changes
- `onSubmit` - form submission
- `onKeyPress` - keyboard events
- `onMouseOver` - mouse hover

**💻 Practice Exercise 5:**

Create `src/EventPractice.js`:

```javascript
// EventPractice.js
import { useState } from 'react';

function EventPractice() {
  const [message, setMessage] = useState('Click a button!');
  const [inputText, setInputText] = useState('');
  const [hoverCount, setHoverCount] = useState(0);
  
  const handleClick = () => {
    setMessage('Button was clicked!');
  };
  
  const handleDoubleClick = () => {
    setMessage('Double clicked!');
  };
  
  const handleInputChange = (e) => {
    setInputText(e.target.value);
    setMessage(`Typing: ${e.target.value}`);
  };
  
  const handleMouseEnter = () => {
    setHoverCount(hoverCount + 1);
    setMessage('Mouse entered!');
  };
  
  const handleMouseLeave = () => {
    setMessage('Mouse left!');
  };
  
  const handleFormSubmit = (e) => {
    e.preventDefault(); // Prevent page refresh
    setMessage(`Form submitted with: ${inputText}`);
    setInputText('');
  };
  
  return (
    <div style={{
      padding: '20px',
      border: '2px solid #2196F3',
      borderRadius: '8px',
      maxWidth: '500px',
      margin: '20px auto'
    }}>
      <h2>Event Handling Practice</h2>
      
      <p style={{ fontSize: '18px', color: '#2196F3' }}>
        {message}
      </p>
      
      <p>Hover count: {hoverCount}</p>
      
      <div style={{ margin: '20px 0' }}>
        <button
          onClick={handleClick}
          style={{ margin: '5px', padding: '10px' }}
        >
          Click Me
        </button>
        
        <button
          onDoubleClick={handleDoubleClick}
          style={{ margin: '5px', padding: '10px' }}
        >
          Double Click Me
        </button>
        
        <button
          onMouseEnter={handleMouseEnter}
          onMouseLeave={handleMouseLeave}
          style={{ margin: '5px', padding: '10px' }}
        >
          Hover Over Me
        </button>
      </div>
      
      <form onSubmit={handleFormSubmit}>
        <input
          type="text"
          value={inputText}
          onChange={handleInputChange}
          placeholder="Type something..."
          style={{
            padding: '10px',
            width: '70%',
            fontSize: '16px'
          }}
        />
        <button
          type="submit"
          style={{
            padding: '10px 20px',
            marginLeft: '10px',
            fontSize: '16px'
          }}
        >
          Submit
        </button>
      </form>
    </div>
  );
}

export default EventPractice;
```

Add to `App.js`:
```javascript
import EventPractice from './EventPractice';

// In return:
<EventPractice />
```

**✅ Checkpoint:** Events working? Perfect!

---

### Step 7: Learn Conditional Rendering (30-40 minutes)

**📖 Learning Resources:**
- **React Docs:** https://react.dev/learn/conditional-rendering

**What is Conditional Rendering?**
- Show/hide elements based on conditions
- Use `if/else`, `&&`, or ternary operator `? :`

**💻 Practice Exercise 6:**

Create `src/LoginForm.js`:

```javascript
// LoginForm.js
import { useState } from 'react';

function LoginForm() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  
  const handleLogin = (e) => {
    e.preventDefault();
    
    // Simple validation
    if (username === 'admin' && password === 'password') {
      setIsLoggedIn(true);
      setError('');
    } else {
      setError('Invalid username or password');
    }
  };
  
  const handleLogout = () => {
    setIsLoggedIn(false);
    setUsername('');
    setPassword('');
  };
  
  // Conditional rendering based on login status
  if (isLoggedIn) {
    return (
      <div style={{
        padding: '20px',
        border: '2px solid #4CAF50',
        borderRadius: '8px',
        maxWidth: '400px',
        margin: '20px auto',
        textAlign: 'center'
      }}>
        <h2>Welcome, {username}!</h2>
        <p>You are logged in.</p>
        <button
          onClick={handleLogout}
          style={{
            padding: '10px 20px',
            backgroundColor: '#f44336',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Logout
        </button>
      </div>
    );
  }
  
  return (
    <div style={{
      padding: '20px',
      border: '2px solid #2196F3',
      borderRadius: '8px',
      maxWidth: '400px',
      margin: '20px auto'
    }}>
      <h2>Login Form</h2>
      
      <form onSubmit={handleLogin}>
        <div style={{ marginBottom: '15px' }}>
          <input
            type="text"
            placeholder="Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            style={{
              padding: '10px',
              width: '100%',
              fontSize: '16px',
              boxSizing: 'border-box'
            }}
          />
        </div>
        
        <div style={{ marginBottom: '15px' }}>
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            style={{
              padding: '10px',
              width: '100%',
              fontSize: '16px',
              boxSizing: 'border-box'
            }}
          />
        </div>
        
        {/* Conditional error message */}
        {error && (
          <p style={{ color: 'red', marginBottom: '10px' }}>
            {error}
          </p>
        )}
        
        <button
          type="submit"
          style={{
            padding: '10px 20px',
            width: '100%',
            fontSize: '16px',
            backgroundColor: '#4CAF50',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Login
        </button>
      </form>
      
      <p style={{ marginTop: '15px', fontSize: '12px', color: '#999' }}>
        Try: username: "admin", password: "password"
      </p>
    </div>
  );
}

export default LoginForm;
```

**Different conditional rendering patterns:**

```javascript
// Pattern 1: if/else (early return)
if (condition) {
  return <ComponentA />;
}
return <ComponentB />;

// Pattern 2: Ternary operator
{condition ? <ComponentA /> : <ComponentB />}

// Pattern 3: Logical AND (show/hide)
{condition && <Component />}

// Pattern 4: Multiple conditions
{condition1 && <Component1 />}
{condition2 && <Component2 />}
{!condition1 && !condition2 && <DefaultComponent />}
```

Add to `App.js`:
```javascript
import LoginForm from './LoginForm';

// In return:
<LoginForm />
```

**✅ Checkpoint:** Conditional rendering working? Great!

---

### Step 8: Learn Lists and Keys (30-40 minutes)

**📖 Learning Resources:**
- **React Docs:** https://react.dev/learn/rendering-lists

**What are Lists?**
- Rendering arrays of data
- Use `map()` to transform array to JSX
- Each item needs a unique `key` prop

**💻 Practice Exercise 7:**

Create `src/ProductList.js`:

```javascript
// ProductList.js
import { useState } from 'react';

function ProductList() {
  const [products] = useState([
    { id: 1, name: 'Laptop', price: 999, inStock: true },
    { id: 2, name: 'Mouse', price: 25, inStock: true },
    { id: 3, name: 'Keyboard', price: 75, inStock: false },
    { id: 4, name: 'Monitor', price: 299, inStock: true },
    { id: 5, name: 'Webcam', price: 50, inStock: false }
  ]);
  
  return (
    <div style={{
      padding: '20px',
      maxWidth: '600px',
      margin: '20px auto',
      border: '1px solid #ddd',
      borderRadius: '8px'
    }}>
      <h2>Product List</h2>
      
      <ul style={{ listStyle: 'none', padding: 0 }}>
        {products.map(product => (
          <li
            key={product.id} // Important: unique key!
            style={{
              padding: '15px',
              margin: '10px 0',
              backgroundColor: '#f9f9f9',
              borderRadius: '4px',
              border: '1px solid #ddd'
            }}
          >
            <h3>{product.name}</h3>
            <p>Price: ${product.price}</p>
            <p style={{
              color: product.inStock ? 'green' : 'red',
              fontWeight: 'bold'
            }}>
              {product.inStock ? '✓ In Stock' : '✗ Out of Stock'}
            </p>
          </li>
        ))}
      </ul>
      
      {/* Filtered list example */}
      <h3>In Stock Products Only:</h3>
      <ul style={{ listStyle: 'none', padding: 0 }}>
        {products
          .filter(product => product.inStock)
          .map(product => (
            <li key={product.id} style={{
              padding: '10px',
              margin: '5px 0',
              backgroundColor: '#e8f5e9'
            }}>
              {product.name} - ${product.price}
            </li>
          ))
        }
      </ul>
    </div>
  );
}

export default ProductList;
```

**Key Points:**
- Always use `key` prop when rendering lists
- `key` should be unique (usually ID)
- Never use array index as key (unless list never changes)
- Keys help React identify which items changed

Add to `App.js`:
```javascript
import ProductList from './ProductList';

// In return:
<ProductList />
```

**✅ Checkpoint:** Lists working? Perfect!

---

### Step 9: Review and Build a Complete App (30-40 minutes)

**💻 Final Challenge: Build a Simple Task Manager**

Combine everything you learned:
- Components
- Props
- State (useState)
- Event Handling
- Conditional Rendering
- Lists and Keys

Create `src/TaskManager.js`:

```javascript
// TaskManager.js - Complete app using all concepts
import { useState } from 'react';

function TaskManager() {
  const [tasks, setTasks] = useState([
    { id: 1, text: 'Learn React', completed: false, priority: 'high' },
    { id: 2, text: 'Build VIRTUOMATE app', completed: false, priority: 'high' },
    { id: 3, text: 'Practice coding', completed: true, priority: 'medium' }
  ]);
  const [newTask, setNewTask] = useState('');
  const [filter, setFilter] = useState('all'); // all, active, completed
  
  const addTask = () => {
    if (newTask.trim()) {
      setTasks([...tasks, {
        id: Date.now(),
        text: newTask,
        completed: false,
        priority: 'medium'
      }]);
      setNewTask('');
    }
  };
  
  const toggleTask = (id) => {
    setTasks(tasks.map(task =>
      task.id === id ? { ...task, completed: !task.completed } : task
    ));
  };
  
  const deleteTask = (id) => {
    setTasks(tasks.filter(task => task.id !== id));
  };
  
  const filteredTasks = tasks.filter(task => {
    if (filter === 'active') return !task.completed;
    if (filter === 'completed') return task.completed;
    return true;
  });
  
  const completedCount = tasks.filter(t => t.completed).length;
  const activeCount = tasks.filter(t => !t.completed).length;
  
  return (
    <div style={{
      padding: '20px',
      maxWidth: '600px',
      margin: '20px auto',
      border: '2px solid #2196F3',
      borderRadius: '8px'
    }}>
      <h1>Task Manager</h1>
      
      {/* Stats */}
      <div style={{
        display: 'flex',
        justifyContent: 'space-around',
        marginBottom: '20px',
        padding: '10px',
        backgroundColor: '#f5f5f5',
        borderRadius: '4px'
      }}>
        <div>
          <strong>Total:</strong> {tasks.length}
        </div>
        <div>
          <strong>Active:</strong> {activeCount}
        </div>
        <div>
          <strong>Completed:</strong> {completedCount}
        </div>
      </div>
      
      {/* Add task form */}
      <div style={{ marginBottom: '20px' }}>
        <input
          type="text"
          value={newTask}
          onChange={(e) => setNewTask(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && addTask()}
          placeholder="Add a new task..."
          style={{
            padding: '10px',
            width: '70%',
            fontSize: '16px',
            marginRight: '10px'
          }}
        />
        <button
          onClick={addTask}
          style={{
            padding: '10px 20px',
            fontSize: '16px',
            backgroundColor: '#4CAF50',
            color: 'white',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Add Task
        </button>
      </div>
      
      {/* Filter buttons */}
      <div style={{ marginBottom: '20px' }}>
        <button
          onClick={() => setFilter('all')}
          style={{
            padding: '8px 16px',
            margin: '0 5px',
            backgroundColor: filter === 'all' ? '#2196F3' : '#e0e0e0',
            color: filter === 'all' ? 'white' : 'black',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          All
        </button>
        <button
          onClick={() => setFilter('active')}
          style={{
            padding: '8px 16px',
            margin: '0 5px',
            backgroundColor: filter === 'active' ? '#2196F3' : '#e0e0e0',
            color: filter === 'active' ? 'white' : 'black',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Active
        </button>
        <button
          onClick={() => setFilter('completed')}
          style={{
            padding: '8px 16px',
            margin: '0 5px',
            backgroundColor: filter === 'completed' ? '#2196F3' : '#e0e0e0',
            color: filter === 'completed' ? 'white' : 'black',
            border: 'none',
            borderRadius: '4px',
            cursor: 'pointer'
          }}
        >
          Completed
        </button>
      </div>
      
      {/* Task list */}
      <ul style={{ listStyle: 'none', padding: 0 }}>
        {filteredTasks.length === 0 ? (
          <li style={{
            padding: '20px',
            textAlign: 'center',
            color: '#999'
          }}>
            No tasks found. Add one above!
          </li>
        ) : (
          filteredTasks.map(task => (
            <li
              key={task.id}
              style={{
                padding: '15px',
                margin: '10px 0',
                backgroundColor: task.completed ? '#e8f5e9' : '#fff',
                border: '1px solid #ddd',
                borderRadius: '4px',
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center'
              }}
            >
              <div style={{ flex: 1 }}>
                <span
                  onClick={() => toggleTask(task.id)}
                  style={{
                    textDecoration: task.completed ? 'line-through' : 'none',
                    color: task.completed ? '#999' : '#000',
                    cursor: 'pointer',
                    fontSize: '16px'
                  }}
                >
                  {task.text}
                </span>
                <span style={{
                  marginLeft: '10px',
                  padding: '2px 8px',
                  backgroundColor: task.priority === 'high' ? '#f44336' : '#ff9800',
                  color: 'white',
                  borderRadius: '4px',
                  fontSize: '12px'
                }}>
                  {task.priority}
                </span>
              </div>
              <button
                onClick={() => deleteTask(task.id)}
                style={{
                  padding: '5px 10px',
                  backgroundColor: '#f44336',
                  color: 'white',
                  border: 'none',
                  borderRadius: '4px',
                  cursor: 'pointer'
                }}
              >
                Delete
              </button>
            </li>
          ))
        )}
      </ul>
    </div>
  );
}

export default TaskManager;
```

Add to `App.js`:
```javascript
import TaskManager from './TaskManager';

// In return:
<TaskManager />
```

**✅ Challenge Complete!** You've built a full-featured task manager!

---

## 🎉 CONGRATULATIONS! Day 4 Complete!

You've learned:
- ✅ JSX syntax
- ✅ Components (functional components)
- ✅ Props (passing data)
- ✅ State (useState hook)
- ✅ Event Handling
- ✅ Conditional Rendering
- ✅ Lists and Keys
- ✅ Built multiple React apps!

---

## 📝 What's Next?

**Tomorrow (Day 5):** React Fundamentals Part 2
- useEffect hook
- useContext hook
- Custom hooks
- Component lifecycle
- More advanced patterns

**For now:**
- ✅ Review all components you created
- ✅ Make sure you understand useState
- ✅ Practice with the Task Manager
- ✅ Experiment and modify the code
- ✅ Take a break - you've accomplished a lot!

---

## 🆘 Troubleshooting

### React app not starting?
- Make sure you're in the project folder
- Run `npm start` again
- Check for errors in terminal

### Components not showing?
- Check imports are correct
- Make sure you exported the component
- Check browser console for errors

### State not updating?
- Remember: use `setState` function, don't modify state directly
- State updates are asynchronous
- Check if you're using the state setter correctly

### Props not working?
- Check prop names match
- Make sure you're passing props correctly
- Use destructuring for cleaner code

---

## 📚 Additional Resources

**Free Learning Platforms:**
- **React Official Docs** - https://react.dev/learn (best resource!)
- **React Tutorial** - https://react.dev/learn/tutorial-tic-tac-toe
- **FreeCodeCamp** - React course section
- **YouTube:** "React Tutorial for Beginners" (many good channels)

**Practice:**
- Modify the Task Manager
- Create your own components
- Experiment with different props
- Try building a calculator or weather widget

---

## 💡 Important Notes for React Native

**What you learned today applies directly to React Native:**

1. **Components** - Same concept, different components (View, Text, etc.)
2. **Props** - Works exactly the same way
3. **State (useState)** - Identical in React Native
4. **Event Handling** - Same patterns, different events (onPress, etc.)
5. **Conditional Rendering** - Exactly the same
6. **Lists** - Same concept, use FlatList in React Native

**The main differences:**
- Instead of `<div>`, use `<View>`
- Instead of `<p>`, use `<Text>`
- Instead of `<button>`, use `<TouchableOpacity>` or `<Button>`
- Instead of CSS, use StyleSheet API

**You're 80% ready for React Native already!** 🎉

---

**Great job completing Day 4! You now understand React fundamentals! 🚀**

**Tomorrow: More React hooks and advanced patterns!**
