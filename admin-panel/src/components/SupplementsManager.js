import React, { useState, useEffect } from "react";
import {
  Box,
  Button,
  TextField,
  Card,
  CardContent,
  Typography,
  Grid,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Alert,
  Snackbar,
  Stack,
} from "@mui/material";
import api from "../utils/axiosConfig";

function SupplementsManager() {
  const [supplements, setSupplements] = useState([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [successMessage, setSuccessMessage] = useState("");
  const [isEditing, setIsEditing] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [newSupplement, setNewSupplement] = useState({
    name: "",
    description: "",
    benefits: "",
    dosage: "",
    precautions: "",
    imageUrl: "",
  });

  useEffect(() => {
    fetchSupplements();
  }, []);

  const fetchSupplements = async () => {
    try {
      setLoading(true);
      setError("");
      const response = await api.get("/supplements");
      setSupplements(response.data);
    } catch (error) {
      console.error("Failed to fetch supplements:", error);
      setError("Failed to load supplements. Please try again later.");
    } finally {
      setLoading(false);
    }
  };

  const handleAddSupplement = async () => {
    try {
      setError("");
      if (isEditing) {
        await api.patch(`/supplements/${editingId}`, newSupplement);
        setSuccessMessage("Supplement updated successfully!");
        setOpenDialog(false);
        await fetchSupplements();
        resetForm();
      } else {
        await api.post("/supplements", newSupplement);
        setSuccessMessage("Supplement added successfully!");
        setOpenDialog(false);
        await fetchSupplements();
        resetForm();
      }
    } catch (error) {
      console.error("Failed to save supplement:", error);
      setError(
        error.response?.data?.message ||
          (isEditing
            ? "Failed to update supplement. Please try again."
            : "Failed to add supplement. Please try again.")
      );
    }
  };

  const handleEditSupplement = (supplement) => {
    setIsEditing(true);
    setEditingId(supplement._id);
    setNewSupplement({
      name: supplement.name,
      description: supplement.description,
      benefits: supplement.benefits || "",
      dosage: supplement.dosage || "",
      precautions: supplement.precautions || "",
      imageUrl: supplement.imageUrl || "",
    });
    setOpenDialog(true);
  };

  const handleDeleteSupplement = async (id) => {
    if (window.confirm("Are you sure you want to delete this supplement?")) {
      try {
        setError("");
        await api.delete(`/supplements/${id}`);
        setSuccessMessage("Supplement deleted successfully!");
        fetchSupplements();
      } catch (error) {
        console.error("Failed to delete supplement:", error);
        setError("Failed to delete supplement. Please try again.");
      }
    }
  };

  const resetForm = () => {
    setNewSupplement({
      name: "",
      description: "",
      benefits: "",
      dosage: "",
      precautions: "",
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
          Supplements
        </Typography>
        <Button
          variant="contained"
          color="primary"
          onClick={() => setOpenDialog(true)}
        >
          Add New Supplement
        </Button>
      </Box>

      {error && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {error}
        </Alert>
      )}

      {loading ? (
        <Typography>Loading supplements...</Typography>
      ) : (
        <Grid container spacing={3}>
          {supplements.map((supplement) => (
            <Grid item xs={12} md={6} key={supplement._id}>
              <Card>
                <CardContent>
                  <Typography variant="h6">{supplement.name}</Typography>
                  <Typography variant="body2" paragraph>
                    {supplement.description}
                  </Typography>
                  {supplement.benefits && (
                    <Typography variant="body2" color="textSecondary">
                      Benefits: {supplement.benefits}
                    </Typography>
                  )}
                  {supplement.dosage && (
                    <Typography variant="body2" color="textSecondary">
                      Dosage: {supplement.dosage}
                    </Typography>
                  )}
                  {supplement.precautions && (
                    <Typography variant="body2" color="textSecondary">
                      Precautions: {supplement.precautions}
                    </Typography>
                  )}
                  {supplement.imageUrl && (
                    <Box sx={{ mt: 2, mb: 2 }}>
                      <img
                        src={supplement.imageUrl}
                        alt={supplement.name}
                        style={{ maxWidth: "100%", height: "auto" }}
                      />
                    </Box>
                  )}
                  <Stack direction="row" spacing={2} sx={{ mt: 2 }}>
                    <Button
                      color="primary"
                      onClick={() => handleEditSupplement(supplement)}
                    >
                      Edit
                    </Button>
                    <Button
                      color="error"
                      onClick={() => handleDeleteSupplement(supplement._id)}
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
        <DialogTitle>
          {isEditing ? "Edit Supplement" : "Add New Supplement"}
        </DialogTitle>
        <DialogContent>
          <Box sx={{ pt: 2 }}>
            <TextField
              fullWidth
              label="Name"
              value={newSupplement.name}
              onChange={(e) =>
                setNewSupplement({ ...newSupplement, name: e.target.value })
              }
              margin="normal"
              required
            />
            <TextField
              fullWidth
              label="Description"
              value={newSupplement.description}
              onChange={(e) =>
                setNewSupplement({
                  ...newSupplement,
                  description: e.target.value,
                })
              }
              margin="normal"
              multiline
              rows={3}
              required
            />
            <TextField
              fullWidth
              label="Benefits"
              value={newSupplement.benefits}
              onChange={(e) =>
                setNewSupplement({ ...newSupplement, benefits: e.target.value })
              }
              margin="normal"
              multiline
              rows={3}
              helperText="Enter the benefits, one per line"
            />
            <TextField
              fullWidth
              label="Dosage"
              value={newSupplement.dosage}
              onChange={(e) =>
                setNewSupplement({ ...newSupplement, dosage: e.target.value })
              }
              margin="normal"
              helperText="e.g., '1000mg daily'"
              required
            />
            <TextField
              fullWidth
              label="Precautions"
              value={newSupplement.precautions}
              onChange={(e) =>
                setNewSupplement({
                  ...newSupplement,
                  precautions: e.target.value,
                })
              }
              margin="normal"
              multiline
              rows={2}
              helperText="Enter any warnings or precautions"
            />
            <TextField
              fullWidth
              label="Image URL"
              value={newSupplement.imageUrl}
              onChange={(e) =>
                setNewSupplement({ ...newSupplement, imageUrl: e.target.value })
              }
              margin="normal"
              helperText="Enter the URL of the supplement image"
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>Cancel</Button>
          <Button
            onClick={handleAddSupplement}
            color="primary"
            disabled={
              !newSupplement.name ||
              !newSupplement.description ||
              !newSupplement.dosage
            }
          >
            {isEditing ? "Save Changes" : "Add Supplement"}
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

export default SupplementsManager;
