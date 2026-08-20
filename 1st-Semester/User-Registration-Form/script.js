document.getElementById("registrationForm").addEventListener ("submit",function(event) {
    // prevent default submission
    event.preventDefault();

    let fullname=document.getElementById("fullname").value.trim();
    let email = document.getElementById("email").value.trim();
    let password = document.getElementById("password").value;
    let confirmPassword = document.getElementById("confirmpassword").value;
    let age = document.getElementById("age").value;

    // validating the name 
    let nameParts = fullname.split(" ");


    if (fullname === "" || nameParts.length < 2){
        alert("Full Name must contain at least 2 words.") ;
         return ;
    }
        
    // validating email
    if(!email.includes("@")|| !email.includes(".")){
        alert("Please enter a valid email address.");
        return;
    }

    // Check password length
    if (password.length < 8) {
        alert("Password must be at least 8 characters long.");
        return;
    }

    // Check for uppercase letter
     if (password === password.toLowerCase()) {
        alert("Password must contain at least one uppercase letter.");
        return;
    }

    // Check for number
    
    let hasNumber = false;
    for (let i = 0; i < password.length; i++) {
        if (!isNaN(password[i]) && password[i] !== " ") {
            hasNumber = true;
        }
    }
    
    if (!hasNumber) {
        alert("Password must contain at least one number.");
        return;
    }
    
    // Check for special character 
    
    let specialCharacters = "!@#$%^&*()_+-=[]{}|;:',.<>?/";
    let hasSpecialCharacter = false;
    for (let i = 0; i < password.length; i++) {
        if (specialCharacters.includes(password[i])) {
            hasSpecialCharacter = true;
        }
    }
    
    if (!hasSpecialCharacter) {
         alert("Password must contain at least one special character.");
         return;
    }
     
  // check for the password 
  if (password !== confirmPassword){
    alert("Password do not match.");
  }
  
  // check for age validating
  if (age < 18) {
    alert("You must be 18 years or older.");
    return;
  }


 // successful message
  alert("Registration successful!");

})

// extra point visualizing the email
document.getElementById("email").addEventListener("input", function () {

    if (this.value.includes("@") && this.value.includes(".")) {
        this.style.border = "2px solid green";
    } else {
        this.style.border = "2px solid red";
    }

});