library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)

# --- Input Files and Plot Titles ---

# Create a vector containing the names of all input data files.
file_names <- c(
  "kidney_CC_analysis.csv",
  "kidney_BP_analysis.csv",
  "kidney_MF_analysis.csv",
  "kidney_KEGG_pathways.csv",
  "hepatic_CC_analysis.csv",
  "hepatic_BP_analysis.csv",
  "hepatic_MF_analysis.csv",
  "hepatic_KEGG_pathways.csv"
) 

# Create a named vector to map file names to descriptive titles for each plot.
title_map <- c(
  "kidney_CC_analysis" = "Cellular Component Analysis - Kidney",
  "kidney_BP_analysis" = "Biological Process Analysis - Kidney",
  "kidney_MF_analysis" = "Molecular Function Analysis - Kidney",
  "kidney_KEGG_pathways" = "KEGG Pathway Analysis - Kidney",
  "hepatic_CC_analysis" = "Cellular Component Analysis - Hepatic",
  "hepatic_BP_analysis" = "Biological Process Analysis - Hepatic",
  "hepatic_MF_analysis" = "Molecular Function Analysis - Hepatic",
  "hepatic_KEGG_pathways" = "KEGG Pathway Analysis - Hepatic"
)

# --- Load and Prepare Data ---

# Use lapply to read all CSV files into a list of data frames.
data_list <- lapply(file_names, function(f) read.csv(f, sep = "\t"))

# Assign names to the list elements based on the file names (without the .csv extension).
names(data_list) <- tools::file_path_sans_ext(file_names)

# --- Loop Through Each Dataset to Generate and Save a Plot ---

# Start a 'for' loop that will iterate through each data frame in 'data_list'.
for (name in names(data_list)) {
  
  # Select the current data frame from the list.
  element <- data_list[[name]]
  
  # --- Data Processing and Filtering ---
  
  # Clean the 'Term' names for better readability.
  # This regular expression finds everything from the start of the string (.*)
  # up to the last tilde (~) or colon (:), including any whitespace (\\s*), and replaces it with nothing.
  # Correctly handles all term formats (GO and KEGG).
  element <- element %>%
    mutate(Term = str_replace(Term, ".*[~:]\\s*", ""))
  
  # Process the data for plotting:
  #    - Arrange the data by p-value in ascending order to find the most significant terms.
  #    - Slice the top 20 most significant terms.
  #    - Create an ordered factor for 'Term'. This ensure ggplot2
  #      plots the bars in the correct order (most significant at the top).
  #    - 'rev()' reverses the order so the smallest P-value appears at the top of the y-axis.
  element_plot <- element %>% 
    arrange(PValue) %>%
    slice(1:20) %>%
    mutate(Term = factor(Term, levels = rev(unique(Term))))
  
  # --- Plot Generation with ggplot2 ---
  
  # Create the plot object.
  p <- ggplot(data = element_plot, aes(x = Term, y = Count, fill = PValue)) +
    
    # Add bars. 'stat = "identity"' means the bar height is taken directly from the 'Count' column.
    # 'color' and 'linewidth' add a thin black border to the bars.
    geom_bar(stat = "identity", color = "black", linewidth = 0.3) +
    
    # Flip the coordinates to make the bar plot horizontal.
    coord_flip() +
    
    # Add text labels for the P-values on each bar.
    # 'hjust = -0.2' positions the text slightly outside the end of the bar.
    geom_text(
      aes(label = format(PValue, scientific = TRUE, digits = 2)), 
      hjust = -0.2,
      size = 3,
      color = "black"
    ) +
    
    # Define the color gradient for the bar fill with softer colors.
    # 'low' corresponds to the lowest P-values (most significant).
    # We use a soft red ("#F8766D") and a soft blue ("#87CEEB").
    scale_fill_gradient(low = "#F8766D", high = "#87CEEB", name = "P-Value") +
    
    # Expand the y-axis limit to make space for the text labels.
    scale_y_continuous(expand = expansion(mult = c(0, .15))) +
    
    # Set the plot titles and axis labels.
    labs(
      title = title_map[[name]],
      x = "Term",
      y = "Gene Count"
    ) +
    
    # Apply a clean, minimal theme.
    theme_minimal(base_size = 12) +
    
    # Further customize the theme for a professional look.
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
      axis.text.y = element_text(size = 10, color = "black"), # Term labels
      axis.text.x = element_text(color = "black"), # Gene Count labels
      axis.title.x = element_text(face = "bold", margin = margin(t = 10)), # Y-axis title
      axis.title.y = element_text(face = "bold", margin = margin(r = 10)), # X-axis title
      panel.grid.major.y = element_blank(), # Remove horizontal grid lines
      panel.grid.minor.x = element_blank(), # Remove minor vertical grid lines
      legend.position = "right"
    )
  
  # --- Save the Plot ---
  
  # Define the output filename based on the input data name.
  output_filename_png <- paste0(name, "_barplot.png")
  output_filename_tiff <- paste0(name, "_barplot.tiff")
  
  # Save the generated plot 'p' to a PNG file.
  ggsave(
    output_filename_png,
    plot = p,
    width = 11,
    height = 8,
    dpi = 300,
    bg = "white" # Set a white background for the saved image
  )
  
  # Save the generated plot 'p' to a TIFF file.
  ggsave(
    output_filename_tiff,
    plot = p,
    width = 11,
    height = 8,
    dpi = 300,
    bg = "white" # Set a white background for the saved image
  )
  
  # Print a confirmation message to the console.
  print(paste("PNG plot saved as:", output_filename_png))
  print(paste("TIFF plot saver as:", output_filename_tiff))
}


