# Simplified STAAR Gene-Centric Results Extraction Script
# Based on diagnostic findings: out[[gene]]$category structure

# Set working directory
setwd("/Volumes/T7/WES/staar_results/variant/unconditional_gene_centric_coding")

# Function to safely convert matrix values to character
safe_convert_matrix <- function(mat) {
  if (is.null(mat) || !is.matrix(mat)) {
    return(NULL)
  }
  
  # Convert to data frame
  df <- as.data.frame(mat, stringsAsFactors = FALSE)
  
  # Safely convert each column
  for (col in colnames(df)) {
    df[[col]] <- sapply(df[[col]], function(x) {
      if (is.list(x) || length(x) > 1) {
        return(toString(x))  # Convert complex objects to string
      } else {
        return(as.character(x))
      }
    })
  }
  
  return(df)
}

# Function to extract results from a single chromosome
extract_chromosome_simple <- function(chr_num) {
  cat("Processing chromosome", chr_num, "...\n")
  
  # Construct filename
  filename <- paste0("crc_wes_gene_centric_coding_chr", chr_num, ".Rdata")
  
  if (!file.exists(filename)) {
    cat("Warning: File not found:", filename, "\n")
    return(NULL)
  }
  
  # Load file
  load_env <- new.env()
  load(filename, envir = load_env)
  
  if (!exists("out", envir = load_env)) {
    cat("Warning: 'out' object not found\n")
    return(NULL)
  }
  
  out_data <- load_env$out
  cat("Found", length(out_data), "genes\n")
  
  # Categories to process
  categories <- c("plof", "plof_ds", "missense", "disruptive_missense", "synonymous")
  
  # Store results by category
  category_results <- list()
  for (cat in categories) {
    category_results[[cat]] <- list()
  }
  
  # Process each gene
  for (i in seq_along(out_data)) {
    gene_data <- out_data[[i]]
    
    if (!is.list(gene_data)) next
    
    for (category in categories) {
      if (category %in% names(gene_data)) {
        cat_matrix <- gene_data[[category]]
        
        # Skip if NULL or problematic
        if (is.null(cat_matrix)) next
        
        # Try to convert safely
        cat_df <- safe_convert_matrix(cat_matrix)
        
        if (!is.null(cat_df) && nrow(cat_df) > 0) {
          # Add chromosome info
          cat_df$Chr <- paste0("chr", chr_num)
          category_results[[category]][[length(category_results[[category]]) + 1]] <- cat_df
        }
      }
    }
  }
  
  # Combine results within each category
  final_results <- list()
  
  for (category in categories) {
    if (length(category_results[[category]]) > 0) {
      cat("  ", category, ":", length(category_results[[category]]), "genes\n")
      
      # Combine all results for this category
      tryCatch({
        combined <- do.call(rbind, category_results[[category]])
        final_results[[category]] <- combined
      }, error = function(e) {
        cat("    Error combining", category, ":", e$message, "\n")
      })
    }
  }
  
  # Now combine across categories, using only common columns
  if (length(final_results) > 0) {
    # Find common columns
    all_cols <- lapply(final_results, colnames)
    common_cols <- Reduce(intersect, all_cols)
    
    cat("Common columns:", length(common_cols), "\n")
    if (chr_num == 1) {
      cat("Columns:", paste(common_cols, collapse = ", "), "\n")
    }
    
    # Subset to common columns and combine
    standardized <- lapply(final_results, function(df) df[, common_cols, drop = FALSE])
    final_combined <- do.call(rbind, standardized)
    
    cat("Total results:", nrow(final_combined), "\n")
    return(final_combined)
  }
  
  return(NULL)
}

# Function to create publication table
create_publication_table <- function(results_df, significance_threshold = 3.57E-07, top_n = 100) {
  if (is.null(results_df) || nrow(results_df) == 0) {
    return(NULL)
  }
  
  # Convert STAAR-O p-values to numeric
  staar_o_pvals <- suppressWarnings(as.numeric(results_df$`STAAR-O`))
  
  # Filter for significant results or top N
  significant_indices <- which(staar_o_pvals < significance_threshold & !is.na(staar_o_pvals))
  
  if (length(significant_indices) == 0) {
    cat("No results meet significance threshold. Showing top", min(top_n, nrow(results_df)), "results\n")
    sorted_indices <- order(staar_o_pvals, na.last = TRUE)[1:min(top_n, nrow(results_df))]
    top_results <- results_df[sorted_indices, ]
  } else {
    cat("Found", length(significant_indices), "significant results\n")
    top_results <- results_df[significant_indices, ]
    top_results <- top_results[order(as.numeric(top_results$`STAAR-O`)), ]
  }
  
  # Create clean publication table
  pub_table <- data.frame(
    Gene = top_results$`Gene name`,
    Chr = top_results$Chr,
    Category = top_results$Category,
    SNV_Count = top_results$`#SNV`,
    cMAC = round(as.numeric(top_results$cMAC), 1),
    SKAT_1_25 = sprintf("%.3e", as.numeric(top_results$`SKAT(1,25)`)),
    Burden_1_25 = sprintf("%.3e", as.numeric(top_results$`Burden(1,25)`)),
    ACAT_V_1_25 = sprintf("%.3e", as.numeric(top_results$`ACAT-V(1,25)`)),
    STAAR_O = sprintf("%.3e", as.numeric(top_results$`STAAR-O`)),
    stringsAsFactors = FALSE
  )
  
  return(pub_table)
}

# Main execution
cat("=== SIMPLIFIED STAAR EXTRACTION ===\n")

# Test with chromosome 1
cat("\n--- Testing Chromosome 1 ---\n")
chr1_data <- extract_chromosome_simple(1)

if (!is.null(chr1_data)) {
  cat("\nSUCCESS! Sample of extracted data:\n")
  print(head(chr1_data, 5))
  
  # Create publication table
  pub_table <- create_publication_table(chr1_data, top_n = 20)
  if (!is.null(pub_table)) {
    cat("\nTop results:\n")
    print(head(pub_table, 10))
    
    # Save test files
    write.csv(chr1_data, "chr1_test_results.csv", row.names = FALSE)
    write.csv(pub_table, "chr1_test_publication.csv", row.names = FALSE)
    cat("\nSaved test files: chr1_test_results.csv, chr1_test_publication.csv\n")
  }
  
  # If successful, process all chromosomes
  cat("\n=== PROCESSING ALL CHROMOSOMES ===\n")
  
  all_results <- list()
  
  for (chr in 1:22) {
    cat("\n--- Chromosome", chr, "---\n")
    chr_data <- extract_chromosome_simple(chr)
    
    if (!is.null(chr_data)) {
      all_results[[paste0("chr", chr)]] <- chr_data
      
      # Save individual chromosome results
      write.csv(chr_data, paste0("STAAR_chr", chr, "_results.csv"), row.names = FALSE)
      
      # Create and save publication table for this chromosome
      chr_pub <- create_publication_table(chr_data, top_n = 50)
      if (!is.null(chr_pub)) {
        write.csv(chr_pub, paste0("STAAR_chr", chr, "_publication.csv"), row.names = FALSE)
      }
    }
  }
  
  # Combine all results
  if (length(all_results) > 0) {
    cat("\n=== COMBINING ALL RESULTS ===\n")
    
    master_data <- do.call(rbind, all_results)
    cat("Master dataset:", nrow(master_data), "gene-category combinations\n")
    
    # Create master publication table
    master_pub <- create_publication_table(master_data, top_n = 200)
    
    # Save master files
    write.csv(master_data, "STAAR_MASTER_all_results.csv", row.names = FALSE)
    write.csv(master_pub, "STAAR_MASTER_publication.csv", row.names = FALSE)
    
    cat("\n=== SUMMARY STATISTICS ===\n")
    cat("Total results:", nrow(master_data), "\n")
    cat("By chromosome:\n")
    print(table(master_data$Chr))
    cat("\nBy category:\n")
    print(table(master_data$Category))
    
    # Show top results
    cat("\n=== TOP 20 RESULTS ===\n")
    print(head(master_pub, 20))
    
    cat("\n=== FILES CREATED ===\n")
    cat("- Individual chromosome results: STAAR_chr[1-22]_results.csv\n")
    cat("- Individual chromosome publications: STAAR_chr[1-22]_publication.csv\n")
    cat("- Master results: STAAR_MASTER_all_results.csv\n")
    cat("- Master publication: STAAR_MASTER_publication.csv\n")
    
  } else {
    cat("No results found across chromosomes\n")
  }
  
} else {
  cat("FAILED to extract chromosome 1\n")
}

cat("\n=== EXTRACTION COMPLETE ===\n")
