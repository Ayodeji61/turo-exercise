require("dotenv").config();
const express = require("express");
const app = express();

const port = process.env.PORT || 80;

// Environment variables to expose
const exposedEnv = {
  welcomeMessage: process.env.WELCOME_MESSAGE || "Default welcome message",
};



app.use(express.static("public"));

app.get("/env", (req, res) => {
  res.json(exposedEnv);
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
