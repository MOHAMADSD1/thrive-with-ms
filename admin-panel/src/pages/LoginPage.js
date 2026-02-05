import React, { useState } from "react";
import {
  Box,
  Card,
  CardContent,
  TextField,
  Button,
  Typography,
  Alert,
} from "@mui/material";
import { useNavigate } from "react-router-dom";
import api from "../utils/axiosConfig";

function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      // Using your existing auth endpoint with CORS headers
      const response = await api.post("/auth/login", {
        email,
        password,
      });

      // Check if user is admin
      if (response.data.user.role !== "admin") {
        throw new Error("Access denied. Admin privileges required.");
      }

      // Store the token
      localStorage.setItem("adminToken", response.data.tokens.access.token);
      navigate("/dashboard");
    } catch (err) {
      console.error("Login error:", err);
      setError(
        err.response?.data?.message ||
          err.message ||
          "Login failed. Please try again."
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      sx={{
        height: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        backgroundColor: "#f5f5f5",
      }}
    >
      <Card sx={{ maxWidth: 400, width: "90%", boxShadow: 3 }}>
        <CardContent sx={{ p: 4 }}>
          <Typography
            variant="h4"
            component="h1"
            gutterBottom
            align="center"
            color="primary"
          >
            Admin Login
          </Typography>
          <Typography
            variant="body2"
            align="center"
            color="textSecondary"
            sx={{ mb: 3 }}
          >
            Access restricted to administrators only
          </Typography>

          <form onSubmit={handleLogin}>
            <TextField
              fullWidth
              label="Email"
              variant="outlined"
              margin="normal"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />

            <TextField
              fullWidth
              label="Password"
              type="password"
              variant="outlined"
              margin="normal"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />

            {error && (
              <Alert severity="error" sx={{ mt: 2 }}>
                {error}
              </Alert>
            )}

            <Button
              type="submit"
              fullWidth
              variant="contained"
              color="primary"
              size="large"
              sx={{ mt: 3 }}
              disabled={loading}
            >
              {loading ? "Logging in..." : "Login"}
            </Button>
          </form>
        </CardContent>
      </Card>
    </Box>
  );
}

export default LoginPage;
