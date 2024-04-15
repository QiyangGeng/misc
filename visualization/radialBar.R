###
install.packages("tidyverse", dependencies = TRUE)

###
library(tidyverse)
library(readxl)

###
data_set <- read_excel("./data.xlsx", sheet = "data", col_names = TRUE)

var <- "variable"
val <- "value"

data <- data_set[order(data_set[[val]], decreasing = TRUE), c(var, val)]
colnames(data) <- c("var", "val")
n <- nrow(data)
data$id <- 1:n

angle <- 90 - 360 * (data$id - 1.0) / n
flip <- angle <= -90

label_info <- data.frame(
  id = data$id, 
  h = data$val + 3, 
  text = sprintf("%s %.2f", data$var, data$val), 
  hjust = ifelse(flip, 1, 0), 
  angle = ifelse(flip, angle + 180, angle)
)

###
palatte <- c("#9c3696", "#cd4b90", "#cda1c8", "#e093b3", "#f4b1ca", "#ce677f", 
             "#d57f93", "#f6838c", "#fe8f80", "#db9282", "#f19175", "#f89031", 
             "#ffb321", "#ffca50", "#588b97", "#2097a3", "#38b7bd", "#77b5b2", 
             "#a8dadb", "#478583", "#64b99d", "#57c677", "#b2dfc3")

p <- ggplot(data, aes(x = as.factor(id), y = val, fill = as.factor(id))) + 
  geom_bar(stat = "identity") +
  scale_fill_manual(values = palatte[1:n]) +
  guides(fill = "none") +
  ylim(-15, 150) + 
  coord_polar(start = -pi / n) +
  theme_minimal() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    plot.margin = unit(rep(-10, 40), "cm")
  ) + 
  geom_text(data = label_info, aes(x = id, y = h, label = text, hjust = hjust), 
            color = "black", fontface = "bold", alpha = 1.0, size = 5.0, 
            angle = label_info$angle, inherit.aes = FALSE)

p

###
# Using large size as text might be wonky o/w
png("plot.png", width = 4600, height = 6800, res = 480)
print(p)
dev.off()
