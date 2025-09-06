# Set working directory
setwd("/Users/xingyifan/Downloads/")

# Load the null model
load("crc_wes_nullmodel.Rdata")

# The object is called 'obj'
nullmodel <- nullobj

cat("=== CONVERTING NULL MODEL IDs ===\n")
cat("Original samples:", length(nullmodel$id), "\n")
cat("First 5 original IDs:", head(nullmodel$id, 5), "\n")

# 1. Convert the main ID vector (id_include)
cat("\n1. Converting id_include vector...\n")
nullmodel$id_include <- sapply(strsplit(nullmodel$id_include, "_"), function(x) x[1])

# 2. Convert names of fitted.values
cat("2. Converting fitted.values names...\n")
if(!is.null(names(nullmodel$fitted.values))) {
  names(nullmodel$fitted.values) <- sapply(strsplit(names(nullmodel$fitted.values), "_"), function(x) x[1])
}

# 3. Convert names of Y
cat("3. Converting Y names...\n")
if(!is.null(names(nullmodel$Y))) {
  names(nullmodel$Y) <- sapply(strsplit(names(nullmodel$Y), "_"), function(x) x[1])
}

# 4. Convert names of residuals
cat("4. Converting residuals names...\n")
if(!is.null(names(nullmodel$residuals))) {
  names(nullmodel$residuals) <- sapply(strsplit(names(nullmodel$residuals), "_"), function(x) x[1])
}

# 5. Convert names of scaled.residuals
cat("5. Converting scaled.residuals names...\n")
if(!is.null(names(nullmodel$scaled.residuals))) {
  names(nullmodel$scaled.residuals) <- sapply(strsplit(names(nullmodel$scaled.residuals), "_"), function(x) x[1])
}

# 6. Convert row/column names of Sigma_i matrix
cat("6. Converting Sigma_i matrix names...\n")
if(!is.null(rownames(nullmodel$Sigma_i))) {
  rownames(nullmodel$Sigma_i) <- sapply(strsplit(rownames(nullmodel$Sigma_i), "_"), function(x) x[1])
}
if(!is.null(colnames(nullmodel$Sigma_i))) {
  colnames(nullmodel$Sigma_i) <- sapply(strsplit(colnames(nullmodel$Sigma_i), "_"), function(x) x[1])
}

# 7. Convert row names of Sigma_iX matrix
cat("7. Converting Sigma_iX matrix names...\n")
if(!is.null(rownames(nullmodel$Sigma_iX))) {
  rownames(nullmodel$Sigma_iX) <- sapply(strsplit(rownames(nullmodel$Sigma_iX), "_"), function(x) x[1])
}

# 8. Convert row names of X matrix
cat("8. Converting X matrix names...\n")
if(!is.null(rownames(nullmodel$X))) {
  rownames(nullmodel$X) <- sapply(strsplit(rownames(nullmodel$X), "_"), function(x) x[1])
}

# 9. Convert row/column names of cov matrix
cat("9. Converting cov matrix names...\n")
if(!is.null(rownames(nullmodel$cov))) {
  rownames(nullmodel$cov) <- sapply(strsplit(rownames(nullmodel$cov), "_"), function(x) x[1])
}
if(!is.null(colnames(nullmodel$cov))) {
  colnames(nullmodel$cov) <- sapply(strsplit(colnames(nullmodel$cov), "_"), function(x) x[1])
}

# Note: The null model doesn't have a direct 'id' field, it uses 'id_include'
# So we create an 'id' field for compatibility
nullmodel$id <- nullmodel$id_include

# Verify the conversion
cat("\n=== VERIFICATION ===\n")
cat("Converted samples:", length(nullmodel$id), "\n")
cat("First 5 converted IDs:", head(nullmodel$id, 5), "\n")

# Check for any remaining underscores
remaining_underscore <- sum(grepl("_", nullmodel$id))
cat("IDs still containing underscore:", remaining_underscore, "\n")

if(remaining_underscore > 0) {
  cat("Warning: Some IDs still contain underscores:\n")
  print(head(nullmodel$id[grepl("_", nullmodel$id)], 5))
}

# Save the modified null model back as 'obj'
obj <- nullmodel

# Save to new file
save(obj, file = "crc_wes_nullmodel_fixed.Rdata")

cat("\n=== CONVERSION COMPLETE ===\n")
cat("Fixed null model saved as: crc_wes_nullmodel_fixed.Rdata\n")
cat("Use this file in your STAAR analysis with:\n")
cat("-inullobj_file='crc_wes_nullmodel_fixed.Rdata'\n")
