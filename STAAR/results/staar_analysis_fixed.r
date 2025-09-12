# Complete R code to process STAAR results from chromosomes 1-22
# and create combined publication table

# Set working directory
setwd("/Volumes/T7/WES/staar_results/SNV/unconditional_gene_centric_coding")

# Function to recursively search for results matrices
find_results_matrix <- function(obj, depth = 0) {
  if (depth > 5) return(NULL)  # Prevent infinite recursion
  
  if (is.matrix(obj) || is.data.frame(obj)) {
    # Check if this looks like STAAR results (91 columns, numeric data)
    if (ncol(obj) == 91 && any(sapply(obj, is.numeric))) {
      return(obj)
    }
  } else if (is.list(obj)) {
    for (i in seq_along(obj)) {
      result <- find_results_matrix(obj[[i]], depth + 1)
      if (!is.null(result)) return(result)
    }
  }
  return(NULL)
}

# Function to format p-values for publication
format_pvalue <- function(pval_string) {
  pval_num <- as.numeric(as.character(pval_string))
  ifelse(is.na(pval_num), "NA",
         ifelse(pval_num < 1e-300, "<1.00E-300",
                ifelse(pval_num < 0.001, 
                       sprintf("%.2E", pval_num),
                       sprintf("%.3f", pval_num))))
}

# Function to create publication table
create_publication_table <- function(results_df, significance_threshold = 3.57E-07, 
                                   top_n = 50) {
  
  if (is.null(results_df) || nrow(results_df) == 0) {
    return(NULL)
  }
  
  # Convert p-values to numeric for filtering
  staar_o_pvals <- as.numeric(as.character(results_df$`STAAR-O`))
  
  # Filter for significant results
  significant_indices <- which(staar_o_pvals < significance_threshold & !is.na(staar_o_pvals))
  
  if (length(significant_indices) == 0) {
    cat("No genes meet the significance threshold of", significance_threshold, "\n")
    cat("Showing top", min(top_n, nrow(results_df)), "genes by STAAR-O p-value instead:\n")
    # Sort by STAAR-O p-value and take top N
    sorted_indices <- order(staar_o_pvals, na.last = TRUE)[1:min(top_n, nrow(results_df))]
    significant_genes <- results_df[sorted_indices, ]
  } else {
    cat("Found", length(significant_indices), "significant genes\n")
    significant_genes <- results_df[significant_indices, ]
    # Sort by STAAR-O p-value
    staar_o_sig <- as.numeric(as.character(significant_genes$`STAAR-O`))
    significant_genes <- significant_genes[order(staar_o_sig), ]
  }
  
  # Create the publication table
  pub_table <- data.frame(
    Gene = as.character(significant_genes$`Gene name`),
    Chr = as.character(significant_genes$Chr),
    Category = as.character(significant_genes$Category),
    `#SNV` = as.character(significant_genes$`#SNV`),
    cMAC = round(as.numeric(as.character(significant_genes$cMAC)), 1),
    SKAT = format_pvalue(significant_genes$`SKAT(1,25)`),
    Burden = format_pvalue(significant_genes$`Burden(1,25)`),
    `ACAT-V` = format_pvalue(significant_genes$`ACAT-V(1,25)`),
    `STAAR-O` = format_pvalue(significant_genes$`STAAR-O`),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  
  return(pub_table)
}

# Function to process a single chromosome
process_chromosome <- function(chr_num) {
  cat("Processing chromosome", chr_num, "...\n")
  
  # Construct filename
  filename <- paste0("crc_wes_gene_centric_coding_chr", chr_num, ".Rdata")
  
  # Check if file exists
  if (!file.exists(filename)) {
    cat("Warning: File", filename, "not found. Skipping chromosome", chr_num, "\n")
    return(NULL)
  }
  
  # Create a new environment for loading
  load_env <- new.env()
  
  # Load the chromosome-specific file into the new environment
  load(filename, envir = load_env)
  
  # Extract results from the nested list structure
  all_results <- list()
  gene_count <- 0
  
  # Check if 'out' object exists in the loaded environment and process it
  if (exists("out", envir = load_env) && !is.null(load_env$out)) {
    out_data <- load_env$out
    for (i in seq_along(out_data)) {
      if (!is.null(out_data[[i]])) {
        result_matrix <- find_results_matrix(out_data[[i]])
        if (!is.null(result_matrix)) {
          gene_count <- gene_count + 1
          all_results[[gene_count]] <- result_matrix
        }
      }
    }
  }
  
  cat("Found results for", gene_count, "genes on chromosome", chr_num, "\n")
  
  # Combine results for this chromosome
  if (length(all_results) > 0) {
    chr_results <- do.call(rbind, lapply(all_results, function(x) {
      if (is.matrix(x)) {
        df <- data.frame(matrix(unlist(x), nrow = nrow(x), byrow = FALSE), 
                         stringsAsFactors = FALSE)
        colnames(df) <- colnames(x)
        return(df)
      } else {
        return(as.data.frame(x, stringsAsFactors = FALSE))
      }
    }))
    
    # Add chromosome identifier if not already present
    chr_results$Chr <- paste0("chr", chr_num)
    
    return(chr_results)
  } else {
    cat("No results found for chromosome", chr_num, "\n")
    return(NULL)
  }
}

# Main analysis workflow
cat("=== STARTING MULTI-CHROMOSOME STAAR ANALYSIS ===\n")

# Initialize storage for all chromosome results
all_chromosome_results <- list()
all_publication_tables <- list()

# Process each chromosome
for (chr in 1:22) {
  cat("\n--- Processing Chromosome", chr, "---\n")
  
  # Process this chromosome
  chr_results <- process_chromosome(chr)
  
  if (!is.null(chr_results)) {
    # Store full results
    all_chromosome_results[[paste0("chr", chr)]] <- chr_results
    
    # Create publication table for this chromosome
    chr_pub_table <- create_publication_table(chr_results)
    
    if (!is.null(chr_pub_table) && nrow(chr_pub_table) > 0) {
      all_publication_tables[[paste0("chr", chr)]] <- chr_pub_table
      
      # Save chromosome-specific publication table
      chr_filename <- paste0("STAAR_chr", chr, "_publication_table.csv")
      write.csv(chr_pub_table, chr_filename, row.names = FALSE)
      cat("Saved chromosome", chr, "publication table to:", chr_filename, "\n")
    }
    
    # Save full chromosome results
    full_chr_filename <- paste0("STAAR_chr", chr, "_all_results.csv")
    write.csv(chr_results, full_chr_filename, row.names = FALSE)
    cat("Saved chromosome", chr, "full results to:", full_chr_filename, "\n")
  }
}

# Combine all chromosome results
cat("\n=== COMBINING RESULTS FROM ALL CHROMOSOMES ===\n")

if (length(all_chromosome_results) > 0) {
  # Combine all chromosome results into one master dataset
  master_results <- do.call(rbind, all_chromosome_results)
  cat("Master dataset contains", nrow(master_results), "genes from", 
      length(all_chromosome_results), "chromosomes\n")
  
  # Create master publication table
  master_publication_table <- create_publication_table(master_results, top_n = 100)
  
  if (!is.null(master_publication_table)) {
    cat("Master publication table contains", nrow(master_publication_table), "genes\n")
    
    # Display the master table
    cat("\n=== MASTER PUBLICATION TABLE (TOP GENES) ===\n")
    print(head(master_publication_table, 20))
    
    # Save master results
    write.csv(master_publication_table, "STAAR_MASTER_publication_table.csv", row.names = FALSE)
    write.csv(master_results, "STAAR_MASTER_all_results.csv", row.names = FALSE)
    write.table(master_publication_table, "STAAR_MASTER_publication_table.txt", 
                sep = "\t", row.names = FALSE, quote = FALSE)
    
    cat("\nSaved master files:\n")
    cat("- STAAR_MASTER_publication_table.csv\n")
    cat("- STAAR_MASTER_all_results.csv\n")
    cat("- STAAR_MASTER_publication_table.txt\n")
    
    # Create markdown table if knitr is available
    if (require(knitr, quietly = TRUE)) {
      markdown_table <- kable(master_publication_table, format = "markdown")
      writeLines(markdown_table, "STAAR_MASTER_table.md")
      cat("- STAAR_MASTER_table.md\n")
    }
  }
} else {
  cat("No results found across all chromosomes. Check file names and paths.\n")
}

# Summary statistics across all chromosomes
if (exists("master_results")) {
  cat("\n=== GENOME-WIDE SUMMARY STATISTICS ===\n")
  staar_o_pvals <- as.numeric(as.character(master_results$`STAAR-O`))
  
  cat("Total genes analyzed across all chromosomes:", nrow(master_results), "\n")
  cat("Genes with STAAR-O p < 0.05:", sum(staar_o_pvals < 0.05, na.rm = TRUE), "\n")
  cat("Genes with STAAR-O p < 0.001:", sum(staar_o_pvals < 0.001, na.rm = TRUE), "\n")
  cat("Genes with STAAR-O p < 3.57E-07 (genome-wide sig):", sum(staar_o_pvals < 3.57E-07, na.rm = TRUE), "\n")
  cat("Range of STAAR-O p-values:", paste(range(staar_o_pvals, na.rm = TRUE), collapse = " to "), "\n")
  
  # Summary by chromosome
  cat("\n=== RESULTS BY CHROMOSOME ===\n")
  chr_summary <- table(master_results$Chr)
  print(chr_summary)
  
  # Summary by functional category
  if ("Category" %in% colnames(master_results)) {
    cat("\n=== RESULTS BY FUNCTIONAL CATEGORY ===\n")
    cat_summary <- table(master_results$Category)
    print(cat_summary)
    
    # Create separate tables by category
    for (cat_name in names(cat_summary)) {
      if (cat_summary[cat_name] > 0) {
        cat_results <- master_results[master_results$Category == cat_name, ]
        cat_table <- create_publication_table(cat_results, top_n = 30)
        
        if (!is.null(cat_table) && nrow(cat_table) > 0) {
          filename <- paste0("STAAR_", gsub("[^A-Za-z0-9]", "_", cat_name), "_MASTER_results.csv")
          write.csv(cat_table, filename, row.names = FALSE)
          cat("Saved", cat_name, "results to:", filename, "\n")
        }
      }
    }
  }
}

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Files generated:\n")
cat("- Individual chromosome tables: STAAR_chr[1-22]_publication_table.csv\n")
cat("- Individual chromosome full results: STAAR_chr[1-22]_all_results.csv\n")
cat("- Master combined table: STAAR_MASTER_publication_table.csv\n")
cat("- Master full results: STAAR_MASTER_all_results.csv\n")
cat("- Category-specific tables: STAAR_[category]_MASTER_results.csv\n")
