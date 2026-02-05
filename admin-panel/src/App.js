import React from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";
import { ThemeProvider, createTheme } from "@mui/material";
import LoginPage from "./pages/LoginPage";
import Dashboard from "./pages/Dashboard";
import { Box } from "@mui/material";


const theme = createTheme({
  palette: {
    primary: {
      main: "#ff9800", 
    },
    secondary: {
      main: "#1a237e", 
    },
  },
});

function App() {
  
  const isAuthenticated = localStorage.getItem("adminToken");

  return (
    <ThemeProvider theme={theme}>
      <Box sx={{ backgroundColor: "#f5f5f5", minHeight: "100vh" }}>
        <Router>
          <Routes>
            <Route
              path="/login"
              element={
                isAuthenticated ? <Navigate to="/dashboard" /> : <LoginPage />
              }
            />
            <Route
              path="/dashboard/*"
              element={
                isAuthenticated ? <Dashboard /> : <Navigate to="/login" />
              }
            />
            <Route
              path="/"
              element={
                <Navigate to={isAuthenticated ? "/dashboard" : "/login"} />
              }
            />
          </Routes>
        </Router>
      </Box>
    </ThemeProvider>
  );
}

export default App;
