# data checks
library(tidyverse)
library(glue)
# library(koboAPI)
library(butteR)
# library(koboloadeR)


# read data ---------------------------------------------------------------

df_tool_data <- readxl::read_excel("inputs/UGA2103_FSP_Assessment_Raw_data_aug_final.xlsx")
df_survey <- readxl::read_excel("inputs/UGA2103_FSP_Tool_June2021_Final_2021_08_20.xlsx", sheet = "survey") 
df_choices <- readxl::read_excel("inputs/UGA2103_FSP_Tool_June2021_Final_2021_08_20.xlsx", sheet = "choices") 

# All “other” responses should be flagged ---------------------------------
# - identify them
# - extract them and their responses
# - add column for re-categorization
# - Keep important columns to help you take them back
# - have some kind of identifier

# get questions with other
others_colnames <-  df_tool_data %>% 
  select(
    ends_with("_other"), -contains("/")
  ) %>% colnames()

# data.frame for holding _other response data
df_other_response_data <- data.frame()

for (cln in others_colnames) {
  check_val_parent <- str_replace(string = cln, pattern = "_other", replacement = "")
  df_filtered_data <- df_tool_data %>% 
    select(
      -contains("/")
    ) %>% 
    select("_uuid", "today", "enumerator_id", other_text = cln, current_value = check_val_parent) %>% 
    filter(!is.na(other_text), !other_text %in% c(" ", "NA")) %>% 
    mutate( other_name = cln, 
            int.my_current_val_extract = ifelse(str_detect(current_value, "other\\b"), str_extract_all(string = current_value, pattern = "other\\b|[a-z]+._other\\b"), current_value),
            appropriate_choice = NA,
            parent_question = check_val_parent
            )
  df_other_response_data <- rbind(df_other_response_data, df_filtered_data)
}
# arrange the data
df_data_arranged <- df_other_response_data %>% 
  arrange(today, `_uuid`)


# add choices to the data -------------------------------------------------

# # gather choice options based on unique choices list
# df_unique_choices <- df_choices %>% 
#   pull(list_name) %>% unique()
# 
# df_grouped_choices <- tibble()
# 
# for (vl in df_unique_choices) {
#   current_data <- df_choices %>% 
#     filter(list_name == vl) %>% pull(name) %>% str_c(collapse = " : ")
#   df_grouped_choices <- bind_rows(df_grouped_choices, tibble(list_name=vl, choice_options = current_data)) }
# 
# df_grouped_choices <- df_grouped_choices %>% 
  # arrange(list_name)

# Option 2:
df_grouped_choices <- df_choices %>% 
  group_by(list_name) %>% 
  summarise(choice_options = paste(name, collapse = " : ")) %>% 
  arrange(list_name)

# extract parent question and join survey for extracting list_name
df_data_parent_qns <- df_data_arranged %>% 
  mutate(
    parent_qn = str_replace_all(other_name, "_other", "")
  ) %>% 
  left_join(df_survey %>% select(name, type), by = c("parent_qn"="name")) %>% 
  separate(col = type, into = c("select_type", "list_name"), sep =" ", remove = TRUE, extra = "drop" ) %>% 
  rename(name = parent_qn)

# join other responses with choice options based on list_name

df_join_other_response_with_choices <- df_data_parent_qns %>% 
  left_join(df_grouped_choices, by = "list_name")

# output the resulting data frame
write_csv(x = df_join_other_response_with_choices, file = paste0("outputs/others_responses_",as_date(today()),"_", hour(now()) ,".csv"), na = "")
