// const axios = require("axios"); 
const bcrypt = require("bcryptjs");
const { ObjectId } = require("mongodb");
const { application } = require("express");
const { stat } = require("fs");
const UsersCollection = require("../db").db("GOSAFEAI").collection("User");
let User = function (data) {
  this.data = data;
  this.errors = [];
};

User.prototype.cleanUp = function () {
  this.data = {
    // Primary Attributes
    name: this.data.name,
    lName: this.data.lName,
    email: this.data.email.trim().toLowerCase(),
    password: this.data.password,
    contactNumber: this.data.contactNumber,
    address: this.data.address,
    city: this.data.city,
    state: this.data.state,
    role: "User",
    createdAt: new Date(),
    
  };
};

// Login method
User.prototype.login = async function () {
  let attemptedUser = await UsersCollection.findOne({
    email: this.data.email,
  });
  this.cleanUp();
  if (
    attemptedUser &&
    bcrypt.compareSync(this.data.password, attemptedUser.password)
  ) {
    this.data = attemptedUser;
    return true;
  } else {
    return false;
  }
};

User.prototype.register = async function () {
  // Clean the User data
  this.cleanUp();

  // Hash the User's password using bcrypt
  let salt = bcrypt.genSaltSync(10); // Create a salt
  this.data.password = bcrypt.hashSync(this.data.password, salt); // Hash the password

  // Insert the User's document into the Users collection
  let result = await UsersCollection.insertOne(this.data);
  let UserId = result.insertedId; // Get the newly created User's ID

  // Find the parent by UserSchoolId (provided by the User)
  if (this.data.UserSchoolId) {
    let parent = await parentsCollection.findOne({
      UserSchoolId: this.data.UserSchoolId,
    });

    if (parent) {
      // Update the parent's collection with User details
      await parentsCollection.updateOne(
        { _id: parent._id },
        {
          $set: {
            UserId: UserId,
            UserName: this.data.name,
            UserEmail: this.data.email,
            UserClass: this.data.class,
            UserSection: this.data.section,
            teacherName: this.data.teachername,
            teacherId: this.data.Teacherid,
            interests: this.data.interests,
            schedule: this.data.schedule,
            schoolName: this.data.schoolName,
          },
        }
      );
      console.log(
        `User linked to parent with SAP ID: ${this.data.UserSchoolId}`
      );
    } else {
      console.log(`No parent found with SAP ID: ${this.data.UserSchoolId}`);
    }
  }

  // Send a registration email
  try {
    await this.sendRegistrationEmail();
    console.log(`Registration email sent to: ${this.data.email}`);
  } catch (error) {
    console.error("Error sending email:", error);
  }

  return true; // Return success
};

// Method to send a registration email
User.prototype.sendRegistrationEmail = async function () {
  // Configure the transporter
  const transporter = nodemailer.createTransport({
    service: "gmail",
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {
      user: process.env.NODEMAILER_ADMIN_EMAIL, // Your email
      pass: process.env.NODEMAILER_ADMIN_PASSWORD, // Your email password
    },
  });

  // Define the email details
  const mailOptions = {
    from: process.env.NODEMAILER_ADMIN_EMAIL,
    to: this.data.email, // Send to the User's email
    subject: "Welcome to UDAAN!",
    html: `
      <h1>Welcome, ${this.data.name}!</h1>
      <p>We are excited to have you as part of the UDAAN community. Here are your details:</p>
      <ul>
        <li><strong>Email:</strong> ${this.data.email}</li>
        <li><strong>Class:</strong> ${this.data.class}</li>
        <li><strong>Section:</strong> ${this.data.section}</li>
        <li><strong>School:</strong> ${this.data.schoolName}</li>
      </ul>
      <p>If you have any questions, feel free to reach out.</p>
      <p>Best regards,<br>The UDAAN Team</p>
    `,
  };
  // Send the email
  await transporter.sendMail(mailOptions);
};
// Find by email method
User.prototype.findByEmail = async function (email) {
  return await UsersCollection.findOne({ email: email });
};
// Check if email exists
User.prototype.doesEmailExist = async function (email) {
  let User = await UsersCollection.findOne({ email: email });
  return !!User; // Return true if User exists, false otherwise
};
// Get by ID method
User.prototype.getById = async function (id) {
  return await UsersCollection.findOne({ _id: new ObjectId(id) });
};
// Get all Users method
User.prototype.getAllUsers = async function () {
  return await UsersCollection.find({}).toArray();
};
// Delete by ID method
User.prototype.deleteById = async function (id) {
  await UsersCollection.deleteOne({ _id: new ObjectId(id) });
};
// Fetch grades by User ID
User.prototype.getGradesByUserId = async function (id) {
  let User = await UsersCollection.findOne({ _id: new ObjectId(id) });
  if (User && User.grades) {
    return User.grades;
  }
  return [];};
// Fetch Interests by ID
User.prototype.getInterestsById = async function (id) {
  let User = await UsersCollection.findOne({ _id: new ObjectId(id) });
  return User ? User.interests : null;
};
//quiz:
User.prototype.getQuizzes = async function () {
  const quizzes = await quizsCollection.find({ UserId: new ObjectId(this.data._id) }).toArray();
  return quizzes;
};
// Fetch Schedule by ID
User.prototype.getScheduleByUserId = async function (id) {
  try {
    const User = await UsersCollection.findOne({ _id: new ObjectId(id) });
    return User ? User.schedule : null; // Ensure `schedule` matches your field name
  } catch (error) {
    console.error("Error fetching schedule:", error);
    throw new Error("Database error while fetching schedule.");
  }
};
//fetch a particular schedule by schedule id and User id
User.prototype.getSpecificSchedule = async function (UserId, scheduleId) {
  try {
    const User = await UsersCollection.findOne({ _id: new ObjectId(UserId) });

    if (User && Array.isArray(User.schedule)) {
      // Find the specific schedule by scheduleId
      return User.schedule.find(s => s._id.toString() === scheduleId) || null;
    }
    return null; // No schedules or User not found
  } catch (error) {
    console.error("Error fetching specific schedule:", error);
    throw new Error("Database error while fetching specific schedule.");
  }
};

//for generarting the schedule(flask and node connection via axios)
User.prototype.generateNewSchedule = async function (id, newScheduleDescription) {
  try {
    // Step 1: Fetch the User's current schedule data
    let User = await UsersCollection.findOne(
      { _id: new ObjectId(id) },
      { projection: { schedule: 1 } }
    );
    if (!User) {
      throw new Error('User not found.');
    }
    // Step 2: Create a new schedule ID and structure for the new schedule
    const newScheduleId = new ObjectId(); // Generate a unique ID for the schedule
    const newSchedule = {
      scheduleId: newScheduleId,
      scheduledescription: newScheduleDescription,
      title: "New Schedule", // Default title, can be updated later
      schedule: {}, // Placeholder for additional data
      status: "Pending",
    };
    // Step 3: Add the new schedule to the User's schedule array
    const updatedSchedule = Array.isArray(User.schedule)
      ? [...User.schedule, newSchedule]
      : [newSchedule];
    // Step 4: Send the updated schedule array to Flask for generation
    const scheduleDescriptions = updatedSchedule.map((schedule) => ({
      scheduleId: schedule.scheduleId || "",
      scheduledescription: schedule.scheduledescription || {},
      title: schedule.title || "",
      status: schedule.status || "Pending",
    }));
    const flaskResponse = await axios.post('http://127.0.0.1:5000/test', { roadmap: roadmapDescriptions });
    // Step 5: Validate Flask's response
    if (!Array.isArray(flaskResponse.data)) {
      throw new Error('Unexpected response format from Flask. Expected an array.');
    }
    const generatedSchedule = flaskResponse.data;
    // Step 6: Update the database with the new schedule array and Flask results
    await UsersCollection.updateOne(
      { _id: new ObjectId(id) },
      {
        $set: {
          schedule: updatedSchedule, // Updated schedule with the new entry
          generatedSchedule: generatedSchedule, // Save generated schedule data
        },
      }
    );
    // Step 7: Return success response
    return {
      success: true,
      generatedSchedule: generatedSchedule,
      flaskResponse: flaskResponse.data,
    };
  } catch (error) {
    console.error('Error in generateNewSchedule:', error.message);
    return {
      success: false,
      message: error.message || 'Error occurred while generating a new schedule.',
    };
  }
};
//getting all the roadmap details
User.prototype.getRoadmapsByUserId = async function (id) {
  try {
    const User = await UsersCollection.findOne({ _id: new ObjectId(id) });
    return User ? User.roadmaps : null; // Adjust "roadmaps" if your field name differs
  } catch (error) {
    console.error("Error fetching roadmaps:", error);
    return null;
  }
};
//getting a specific roadmap by roadmap id and User id
User.prototype.getSpecificRoadmap = async function (UserId, roadmapId) {
  try {
    const User = await UsersCollection.findOne({ _id: new ObjectId(UserId) });

    if (User && Array.isArray(User.roadmap)) {
      // Find the specific roadmap by roadmapId
      return User.roadmap.find(r => r._id.toString() === roadmapId) || null;
    }
    return null; // No roadmaps or User not found
  } catch (error) {
    console.error("Error fetching specific roadmap:", error);
    throw new Error("Database error while fetching specific roadmap.");
  }
};

//for deleting a roadmap
User.prototype.deleteRoadmap = async function (UserId, roadmapId) {
  try {
    // Step 1: Fetch the User's current roadmap data
    let User = await UsersCollection.findOne(
      { _id: new ObjectId(UserId) },
      { projection: { roadmap: 1 } }
    );
    if (!User) {
      throw new Error('User not found.');
    }
    // Step 2: Filter out the roadmap to be deleted
    const updatedRoadmap = Array.isArray(User.roadmap)
      ? User.roadmap.filter((r) => r._id.toString() !== roadmapId)
      : [];
    // Step 3: Update the database with the new roadmap array
    await UsersCollection.updateOne(
      { _id: new ObjectId(UserId) },
      { $set: { roadmap: updatedRoadmap } }
    );
    // Step 4: Return success response
    return { success: true };
  } catch (error) {
    console.error('Error in deleteRoadmap:', error.message);
    return {
      success: false,
      message: error.message || 'Error occurred while deleting the roadmap.',
    };
  }
};

    




// //for generating roadmap...frontend->node->flask->node->frontend
// User.prototype.generateNewRoadmap = async function (id, newRoadmapDescription) {
//   try {
//     // Step 1: Fetch the User's current roadmap data
//     let User = await UsersCollection.findOne(
//       { _id: new ObjectId(id) },
//       { projection: { roadmap: 1 } }
//     );
//     if (!User) {
//       throw new Error('User not found.');
//     }
//     // Step 2: Create a new roadmap ID and structure for the new roadmap
//     const newRoadmapId = new ObjectId(); // Generate a unique ID for the roadmap
//     const newRoadmap = {
//       roadmapId: newRoadmapId,
//       roadmapdescription: newRoadmapDescription,
//       title: "New Roadmap", // Default title, can be updated later
//       roadmap: {}, // Placeholder for additional data
//       status: "Pending",
//     };
//     // Step 3: Add the new roadmap to the User's roadmap array
//     const updatedRoadmap = Array.isArray(User.roadmap)
//       ? [...User.roadmap, newRoadmap]
//       : [newRoadmap];
//     // Step 4: Send the updated roadmap array to Flask for generation
//     const roadmapDescriptions = updatedRoadmap.map((roadmap) => ({
//       roadmapId: roadmap.roadmapId || "",
//       roadmapdescription: roadmap.roadmapdescription || {},
//       title: roadmap.title || "",
//       status: roadmap.status || "Pending",
//     }));
//     const flaskResponse = await axios.post('http://127.0.0.1:5000/test1', { roadmap: roadmapDescriptions });
//     // Step 5: Validate Flask's response
//     if (!Array.isArray(flaskResponse.data)) {
//       throw new Error('Unexpected response format from Flask. Expected an array.');
//     }
//     const generatedRoadmap = flaskResponse.data;
//     // Step 6: Update the database with the new roadmap array and Flask results
//     await UsersCollection.updateOne(
//       { _id: new ObjectId(id) },
//       {
//         $set: {
//           roadmap: updatedRoadmap, // Updated roadmap with the new entry
//           generatedRoadmap: generatedRoadmap, // Save generated roadmap data
//         },
//       }
//     );
//     // Step 7: Return success response
//     return {
//       success: true,
//       generatedRoadmap: generatedRoadmap,
//       flaskResponse: flaskResponse.data,
//     };
//   } catch (error) {
//     console.error('Error in generateNewRoadmap:', error.message);
//     return {
//       success: false,
//       message: error.message || 'Error occurred while generating a new roadmap.',
//     };
//   }
// };

// Fetch Dropout Risk Score by ID from db
User.prototype.getDropoutRiskScoreById = async function (id) {
  try {
    // Step 1: Fetch User data from the database using the given ID
    let User = await UsersCollection.findOne({ _id: new ObjectId(id) }, {
      projection: {
        city: 1,
        state: 1,
        totalfamilyIncome: 1,
        class: 1,
        maritalStatus: 1,
        applicationMode: 1,
        applicationOrder: 1,
        course: 1,
        previousQualification: 1,
        nationality: 1,
        displaced: 1,
        educationalSpecialNeeds: 1,
        debtor: 1,
        tuitionFeesUpToDate: 1,
        courselevel: 1,
        scholarshipHolder: 1,
        ageAtEnrollment: 1,
        mother: 1,
        father: 1,
        grades: 1,
        gender: 1,
        attendance: 1,
      },
    });
    if (!User) {
      throw new Error('User not found');
    }
    // Step 2: Send User data to Flask for dropout risk prediction
    const flaskResponse = await axios.post('http://127.0.0.1:5000/predict-dropout', User);
    // Step 3: Check if Flask returned the expected result
    if (!flaskResponse.data) {
      throw new Error('Error receiving data from Flask');
    }
    // Step 4: Extract dropout risk score from the Flask response
    const dropoutRiskScore = flaskResponse.data.dropoutRisk || null;
    // Step 5: Store the dropout risk score in the database
    await UsersCollection.updateOne(
      { _id: new ObjectId(id) },
      { $set: { dropoutRiskScore: dropoutRiskScore } }
    );
    // Step 6: Return the Flask response and updated dropout risk score in the response
    return {
      success: true,
      dropoutRiskScore: dropoutRiskScore,
      flaskResponse: flaskResponse.data, // Response from Flask with prediction details
    };
    
  } catch (error) {
    console.error('Error in getDropoutRiskScoreById:', error.message);
    return {
      success: false,
      message: error.message || 'Error occurred while processing data.'
    };
  }
};
//Fetch details for scholarship prediction from db(connected with flask via axios)(done)
User.prototype.getScholarshipDetailsById = async function (id) {
  try {
    // Step 1: Fetch relevant User details from the database using the given ID
    let User = await UsersCollection.findOne(
      { _id: new ObjectId(id) },
      {
        projection: {
          city: 1,
          state: 1,
          totalfamilyIncome: 1,
          class: 1,
          courselevel: 1,
          nationality: 1,
          gender: 1,
        },
      }
    );
    if (!User) {
      throw new Error('User not found');
    }
    // Step 2: Send User data to Flask for scholarship eligibility prediction
    const flaskResponse = await axios.post('http://127.0.0.1:5000/test', User);
    // Step 3: Check if Flask returned the expected array result
    if (!Array.isArray(flaskResponse.data)) {
      throw new Error('Unexpected response format from Flask. Expected an array.');
    }
    const scholarshipPredictions = flaskResponse.data; // This will now be an array
    // Step 4: Store the array response in the database under a new field
    await UsersCollection.updateOne(
      { _id: new ObjectId(id) },
      { $set: { scholarshipPredictions: scholarshipPredictions } }
    );
    // Step 5: Return the array response and updated data
    return {
      success: true,
      scholarshipPredictions: scholarshipPredictions,
      flaskResponse: flaskResponse.data, // Full Flask response (array)
    };
  } catch (error) {
    console.error('Error in getScholarshipDetailsById:', error.message);
    return {
      success: false,
      message: error.message || 'Error occurred while processing data.',
    };
  }
};

module.exports = User;
