// GET HTML ELEMENTS

const studentForm = document.getElementById("studentForm");
const studentName = document.getElementById("studentName");
const studentGrade = document.getElementById("studentGrade");
const studentList = document.getElementById("studentList");
const averageGrade = document.getElementById("averageGrade");
const errorMessage = document.getElementById("errorMessage");

// ARRAY TO STORE STUDENTS
let students = [];

studentForm.addEventListener("submit", function(event) {
  event.preventDefault();

  const name = studentName.value.trim();

  const grade = Number(studentGrade.value);

  if (name === "") {

    errorMessage.textContent =
      "Student name cannot be empty";

    return;
  }


  if (grade < 0 || grade > 100 || isNaN(grade)) {

    errorMessage.textContent =
      "Grade must be between 0 and 100";

    return;
  }
 
  // CLEAR ERROR
  errorMessage.textContent = "";


  // CREATE STUDENT OBJECT
  const student = {

    id: Date.now(),

    name: name,

    grade: grade

  };


  // ADD STUDENT TO ARRAY
  students.push(student);

  // DISPLAY STUDENTS
 displayStudents();

 // CLEAR INPUTS
studentForm.reset();
});

// DISPLAY FUNCTION
function displayStudents() {

  // CLEAR OLD TABLE DATA
  studentList.innerHTML = "";

  // GET AVERAGE
 const avg = calculateAverage();

 // LOOP THROUGH STUDENTS
students.forEach(function(student) {
    const row = document.createElement("tr");
    if (student.grade > avg) {
        row.classList.add("above-average");
    }
    row.innerHTML = `

      <td>${student.name}</td>

      <td>${student.grade}</td>

      <td>

        <button
          class="delete-btn"
          onclick="deleteStudent(${student.id})"
        >
          Delete
        </button>

      </td>
    `;

    studentList.appendChild(row);

  });

  averageGrade.textContent =
    avg.toFixed(2);

}

// CALCULATE AVERAGE
function calculateAverage() {

  if (students.length === 0) {
     return 0;
  }

  let total = 0;

  students.forEach(function(student) {
    total = total + student.grade;
  });

  return total / students.length;

}

function deleteStudent(id) {

  students = students.filter(function(student) {

    return student.id !== id;

  });

  displayStudents();

}