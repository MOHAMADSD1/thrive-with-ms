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

function MealsManager() {
  const [meals, setMeals] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");
  const [isEditing, setIsEditing] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [newMeal, setNewMeal] = useState({
    name: "",
    description: "",
    category: "",
    ingredients: [],
    imageUrl: "",
  });

  // Categories matching your backend model
  const categories = ["Breakfast", "Lunch", "Dinner"];

  useEffect(() => {
    fetchMeals();
  }, []);

  const fetchMeals = async () => {
    try {
      setLoading(true);
      setError("");
      const response = await api.get("/meals");
      setMeals(response.data);
    } catch (error) {
      console.error("Failed to fetch meals:", error);
      setError("Failed to load meals. Please try again later.");
    } finally {
      setLoading(false);
    }
  };

  const handleAddMeal = async () => {
    try {
      const mealData = {
        ...newMeal,
        ingredients: newMeal.ingredients
          .split(",")
          .map((item) => item.trim())
          .filter((item) => item !== ""),
      };

      setError("");
      if (isEditing) {
        await api.patch(`/meals/${editingId}`, mealData);
        setSuccessMessage("Meal updated successfully!");
        setOpenDialog(false);
        await fetchMeals(); // Fetch updated data immediately
        resetForm();
      } else {
        await api.post("/meals", mealData);
        setSuccessMessage("Meal added successfully!");
        setOpenDialog(false);
        await fetchMeals(); // Fetch updated data immediately
        resetForm();
      }
    } catch (error) {
      console.error("Failed to save meal:", error);
      setError(
        error.response?.data?.message ||
          (isEditing
            ? "Failed to update meal. Please try again."
            : "Failed to add meal. Please try again.")
      );
    }
  };

  const handleEditMeal = (meal) => {
    setIsEditing(true);
    setEditingId(meal._id);
    setNewMeal({
      name: meal.name,
      description: meal.description,
      category: meal.category,
      ingredients: Array.isArray(meal.ingredients)
        ? meal.ingredients.join(", ")
        : meal.ingredients,
      imageUrl: meal.imageUrl,
    });
    setOpenDialog(true);
  };

  const handleDeleteMeal = async (id) => {
    if (window.confirm("Are you sure you want to delete this meal?")) {
      try {
        setError("");
        await api.delete(`/meals/${id}`);
        setSuccessMessage("Meal deleted successfully!");
        fetchMeals();
      } catch (error) {
        console.error("Failed to delete meal:", error);
        setError("Failed to delete meal. Please try again.");
      }
    }
  };

  const resetForm = () => {
    setNewMeal({
      name: "",
      description: "",
      category: "",
      ingredients: "",
      imageUrl: "",
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
          Meals
        </Typography>
        <Button
          variant="contained"
          color="primary"
          onClick={() => setOpenDialog(true)}
        >
          Add New Meal
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {loading ? (
        <Typography>Loading meals...</Typography>
      ) : (
        <Grid container spacing={3}>
          {meals.map((meal) => (
            <Grid item xs={12} md={6} key={meal._id}>
              <Card>
                <CardContent>
                  <Typography variant="h6">{meal.name}</Typography>
                  <Typography color="textSecondary" gutterBottom>
                    Category: {meal.category}
                  </Typography>
                  <Typography variant="body2" paragraph>
                    {meal.description}
                  </Typography>
                  <Typography variant="body2" color="textSecondary">
                    Ingredients: {meal.ingredients.join(", ")}
                  </Typography>
                  {meal.imageUrl && (
                    <Box sx={{ mt: 2, mb: 2 }}>
                      <img
                        src={meal.imageUrl}
                        alt={meal.name}
                        style={{ maxWidth: "100%", height: "auto" }}
                      />
                    </Box>
                  )}
                  <Stack direction="row" spacing={2} sx={{ mt: 2 }}>
                    <Button
                      color="primary"
                      onClick={() => handleEditMeal(meal)}
                    >
                      Edit
                    </Button>
                    <Button
                      color="error"
                      onClick={() => handleDeleteMeal(meal._id)}
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

      <Dialog
        open={openDialog}
        onClose={handleCloseDialog}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>{isEditing ? "Edit Meal" : "Add New Meal"}</DialogTitle>
        <DialogContent>
          <Box sx={{ pt: 2 }}>
            <TextField
              fullWidth
              label="Name"
              value={newMeal.name}
              onChange={(e) => setNewMeal({ ...newMeal, name: e.target.value })}
              margin="normal"
              required
            />
            <TextField
              fullWidth
              label="Description"
              value={newMeal.description}
              onChange={(e) =>
                setNewMeal({ ...newMeal, description: e.target.value })
              }
              margin="normal"
              multiline
              rows={3}
              required
            />
            <TextField
              fullWidth
              select
              label="Category"
              value={newMeal.category}
              onChange={(e) =>
                setNewMeal({ ...newMeal, category: e.target.value })
              }
              margin="normal"
              required
            >
              {categories.map((category) => (
                <MenuItem key={category} value={category}>
                  {category}
                </MenuItem>
              ))}
            </TextField>
            <TextField
              fullWidth
              label="Ingredients"
              value={newMeal.ingredients}
              onChange={(e) =>
                setNewMeal({ ...newMeal, ingredients: e.target.value })
              }
              margin="normal"
              multiline
              rows={2}
              required
              helperText="Enter ingredients separated by commas (e.g., 'Rice, Chicken, Vegetables')"
            />
            <TextField
              fullWidth
              label="Image URL"
              value={newMeal.imageUrl}
              onChange={(e) =>
                setNewMeal({ ...newMeal, imageUrl: e.target.value })
              }
              margin="normal"
              required
              helperText="Enter the URL of the meal image"
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>Cancel</Button>
          <Button
            onClick={handleAddMeal}
            color="primary"
            disabled={
              !newMeal.name ||
              !newMeal.description ||
              !newMeal.ingredients ||
              !newMeal.imageUrl
            }
          >
            {isEditing ? "Save Changes" : "Add Meal"}
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

export default MealsManager;
