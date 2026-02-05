import React, { useState, useEffect } from "react";
import {
  Box,
  Button,
  TextField,
  Card,
  CardContent,
  Typography,
  Grid,
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Alert,
  Snackbar,
  Stack,
} from "@mui/material";
import api from "../utils/axiosConfig";

function ExercisesManager() {
  const [exercises, setExercises] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");
  const [isEditing, setIsEditing] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [newExercise, setNewExercise] = useState({
    title: "",
    description: "",
    videoId: "",
    category: "",
    duration: "",
    thumbnailUrl: "",
  });

 
  const categories = [
    "strength",
    "stretch",
    "relaxation",
    "balance",
    "mobility",
    "other",
  ];

  
  useEffect(() => {
    fetchExercises();
  }, []);

  const fetchExercises = async () => {
    try {
      setLoading(true);
      setError("");
      const response = await api.get("/exercise");
      setExercises(response.data);
    } catch (error) {
      console.error("Failed to fetch exercises:", error);
      setError("Failed to load exercises. Please try again later.");
    } finally {
      setLoading(false);
    }
  };

  const handleAddExercise = async () => {
    try {
      setError("");
      if (isEditing) {
        await api.patch(`/exercise/${editingId}`, newExercise);
        setSuccessMessage("Exercise updated successfully!");
        setOpenDialog(false);
        await fetchExercises();
        resetForm();
      } else {
        await api.post("/exercise", newExercise);
        setSuccessMessage("Exercise added successfully!");
        setOpenDialog(false);
        await fetchExercises();
        resetForm();
      }
    } catch (error) {
      console.error("Failed to save exercise:", error);
      setError(
        error.response?.data?.message ||
          (isEditing
            ? "Failed to update exercise. Please try again."
            : "Failed to add exercise. Please try again.")
      );
    }
  };

  const handleEditExercise = (exercise) => {
    setIsEditing(true);
    setEditingId(exercise._id);
    setNewExercise({
      title: exercise.title,
      description: exercise.description,
      videoId: exercise.videoId || "",
      category: exercise.category,
      duration: exercise.duration,
      thumbnailUrl: exercise.thumbnailUrl || "",
    });
    setOpenDialog(true);
  };

  const handleDeleteExercise = async (id) => {
    if (window.confirm("Are you sure you want to delete this exercise?")) {
      try {
        setError("");
        await api.delete(`/exercise/${id}`);
        setSuccessMessage("Exercise deleted successfully!");
        fetchExercises();
      } catch (error) {
        console.error("Failed to delete exercise:", error);
        setError("Failed to delete exercise. Please try again.");
      }
    }
  };

  const resetForm = () => {
    setNewExercise({
      title: "",
      description: "",
      videoId: "",
      category: "",
      duration: "",
      thumbnailUrl: "",
    });
    setIsEditing(false);
    setEditingId(null);
  };

  const handleCloseDialog = () => {
    setOpenDialog(false);
    resetForm();
  };

  const handleCloseSnackbar = () => {
    setSuccessMessage("");
  };

  return (
    <Box>
      <Box
        sx={{
          mb: 4,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <Typography variant="h4" component="h1">
          Exercises
        </Typography>
        <Button
          variant="contained"
          color="primary"
          onClick={() => setOpenDialog(true)}
        >
          Add New Exercise
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {/* List of existing exercises */}
      {loading ? (
        <Typography>Loading exercises...</Typography>
      ) : (
        <Grid container spacing={3}>
          {exercises.map((exercise) => (
            <Grid item xs={12} md={6} key={exercise._id}>
              <Card>
                <CardContent>
                  <Typography variant="h6">{exercise.title}</Typography>
                  <Typography color="textSecondary" gutterBottom>
                    Category: {exercise.category}
                  </Typography>
                  <Typography variant="body2" paragraph>
                    {exercise.description}
                  </Typography>
                  <Typography variant="body2" color="textSecondary">
                    Duration: {exercise.duration}
                  </Typography>
                  {exercise.videoId && (
                    <Typography variant="body2" color="textSecondary">
                      Video ID: {exercise.videoId}
                    </Typography>
                  )}
                  {exercise.thumbnailUrl && (
                    <Box sx={{ mt: 2, mb: 2 }}>
                      <img
                        src={exercise.thumbnailUrl}
                        alt={exercise.title}
                        style={{ maxWidth: "100%", height: "auto" }}
                      />
                    </Box>
                  )}
                  <Stack direction="row" spacing={2} sx={{ mt: 2 }}>
                    <Button
                      color="primary"
                      onClick={() => handleEditExercise(exercise)}
                    >
                      Edit
                    </Button>
                    <Button
                      color="error"
                      onClick={() => handleDeleteExercise(exercise._id)}
                    >
                      Delete
                    </Button>
                  </Stack>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

      {/* Dialog for adding new exercise */}
      <Dialog
        open={openDialog}
        onClose={handleCloseDialog}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>
          {isEditing ? "Edit Exercise" : "Add New Exercise"}
        </DialogTitle>
        <DialogContent>
          <Box sx={{ pt: 2 }}>
            <TextField
              fullWidth
              label="Title"
              value={newExercise.title}
              onChange={(e) =>
                setNewExercise({ ...newExercise, title: e.target.value })
              }
              margin="normal"
              required
            />
            <TextField
              fullWidth
              label="Description"
              value={newExercise.description}
              onChange={(e) =>
                setNewExercise({ ...newExercise, description: e.target.value })
              }
              margin="normal"
              multiline
              rows={3}
              required
            />
            <TextField
              fullWidth
              label="YouTube Video ID"
              value={newExercise.videoId}
              onChange={(e) =>
                setNewExercise({ ...newExercise, videoId: e.target.value })
              }
              margin="normal"
              helperText="Enter only the video ID (e.g., 'dQw4w9WgXcQ' from 'youtube.com/watch?v=dQw4w9WgXcQ')"
            />
            <TextField
              fullWidth
              select
              label="Category"
              value={newExercise.category}
              onChange={(e) =>
                setNewExercise({ ...newExercise, category: e.target.value })
              }
              margin="normal"
              required
            >
              {categories.map((category) => (
                <MenuItem key={category} value={category}>
                  {category.charAt(0).toUpperCase() + category.slice(1)}
                </MenuItem>
              ))}
            </TextField>
            <TextField
              fullWidth
              label="Duration (minutes)"
              type="number"
              value={newExercise.duration}
              onChange={(e) =>
                setNewExercise({ ...newExercise, duration: e.target.value })
              }
              margin="normal"
              required
            />
            <TextField
              fullWidth
              label="Thumbnail URL"
              value={newExercise.thumbnailUrl}
              onChange={(e) =>
                setNewExercise({ ...newExercise, thumbnailUrl: e.target.value })
              }
              margin="normal"
              helperText="Enter the URL of the exercise thumbnail image"
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>Cancel</Button>
          <Button
            onClick={handleAddExercise}
            color="primary"
            disabled={
              !newExercise.title ||
              !newExercise.description ||
              !newExercise.duration ||
              !newExercise.category
            }
          >
            {isEditing ? "Save Changes" : "Add Exercise"}
          </Button>
        </DialogActions>
      </Dialog>

      <Snackbar
        open={!!successMessage}
        autoHideDuration={6000}
        onClose={handleCloseSnackbar}
        message={successMessage}
      />
    </Box>
  );
}

export default ExercisesManager;
