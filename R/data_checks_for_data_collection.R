# data checks
library(tidyverse)
library(glue)
library(lubridate)

# rm(list = ls())

# read data ---------------------------------------------------------------

df_tool_data <- readxl::read_excel("inputs/UGA2103_FSP_Assessment_Raw_data_aug_final.xlsx")
df_survey <- readxl::read_excel("inputs/UGA2103_FSP_Tool_June2021_Final_2021_08_20.xlsx", sheet = "survey") 
df_choices <- readxl::read_excel("inputs/UGA2103_FSP_Tool_June2021_Final_2021_08_20.xlsx", sheet = "choices") 

# Time interval for the survey --------------------------------------------

min_time_of_survey <- 60
max_time_of_survey <- 180

df_c_survey_time <-  df_tool_data %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    int.survey_time_interval = difftime(end,start, units = "mins"),
    int.survey_time_interval = round(int.survey_time_interval,2),
    i.check.identified_issue = case_when(
      int.survey_time_interval < min_time_of_survey ~ "less_survey_time",
      int.survey_time_interval > max_time_of_survey ~ "more_survey_time",
      TRUE ~ "normal_survey_time" ),
    i.check.type = NA,
    i.check.name = NA,
    i.check.value = NA,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  )%>% 
  filter(i.check.identified_issue %in% c("less_survey_time", "more_survey_time")) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))


# time_verify_new_agents --------------------------------------------------

# •	time_verify_new_agents should be flagged IF no response is recorded but skip logic was not activated. AND IF response = >20

df_c_time_verify_new_agents <- df_tool_data %>% 
  filter(
    time_verify_new_agents >= 20
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "value_outside_limits",
    i.check.type = NA,
    i.check.name = "time_verify_new_agents",
    i.check.value = time_verify_new_agents,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))

# 
# •	charge_each_transfer should be flagged IF response = >10,000,000  OR “999”  
df_c_charge_each_transfer <- df_tool_data %>% 
  filter(
    charge_each_transfer == 999 | charge_each_transfer >= 10000000
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "value_outside_limits",
    i.check.type = NA,
    i.check.name = "charge_each_transfer",
    i.check.value = as.integer(charge_each_transfer),
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))

# •	fixed_fee should be flagged IF response = > 10,000  OR “999”
df_c_fixed_fee <- df_tool_data %>% 
  filter(
    fixed_fee == 999 | fixed_fee >= 10000
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "value_outside_limits",
    i.check.type = NA,
    i.check.name = "fixed_fee",
    i.check.value = fixed_fee,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))
# •	withdraw_fixed_fee_amount should be flagged IF response = > 10,000 OR “999”
df_c_withdraw_fixed_fee_amount <- df_tool_data %>% 
  filter(
    withdraw_fixed_fee_amount == 999 | withdraw_fixed_fee_amount >= 10000
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "value_outside_limits",
    i.check.type = NA,
    i.check.name = "withdraw_fixed_fee_amount",
    i.check.value = withdraw_fixed_fee_amount,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))
# •	perc_value_delivered should be flagged IF type_FSP = banking institution AND decimal =  >2 
# •	perc_value_delivered should be flagged IF response = > 10    OR “999”
df_c_perc_value_delivered <- df_tool_data %>% 
  filter(
    (organisation_type == "bank" & nchar(strsplit(as.character(perc_value_delivered), "\\.")[[1]][2]) >= 2) | (perc_value_delivered == 999 | perc_value_delivered >= 10)
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "value_outside_limits",
    i.check.type = NA,
    i.check.name = "perc_value_delivered",
    i.check.value = perc_value_delivered,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))

# •	perc_value_withdraw should be flagged IF response = > 10 OR “999” 
df_c_perc_value_withdraw <- df_tool_data %>% 
  filter(
    perc_value_withdraw == 999 | perc_value_withdraw >= 10
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "value_outside_limits",
    i.check.type = NA,
    i.check.name = "perc_value_withdraw",
    i.check.value = perc_value_withdraw,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))

# •	number_agents should be flagged IF response = “999”
df_c_number_agents <- df_tool_data %>% 
  filter(
    number_agents == 999
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "value_outside_limits",
    i.check.type = NA,
    i.check.name = "number_agents",
    i.check.value = number_agents,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))
# •	yes_operate_presence cannot be larger number than number_agents
df_c_yes_operate_presence <- df_tool_data %>% 
  filter(
    yes_operate_presence > number_agents
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "value_outside_limits",
    i.check.type = NA,
    i.check.name = "yes_operate_presence",
    i.check.value = yes_operate_presence,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))
# •	records_kept response should be changed to “all_above” IF “withdrawal” AND “deposit” AND “cash_transfer” are all selected. 
df_c_records_kept <- df_tool_data %>% 
  filter(
    grepl("withdrawal", records_kept, ignore.case=TRUE) & grepl("deposit", records_kept, ignore.case=TRUE) & grepl("cash_transfer", records_kept, ignore.case=TRUE) 
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "response to be changed to all_above",
    i.check.type = NA,
    i.check.name = "records_kept",
    i.check.value = records_kept,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))
# •	monitoring_agent_transparency should be flagged IF response “not_applicable”  Does the organization use agents? Then not applicable should not be answered here. 
df_c_monitoring_agent_transparency <- df_tool_data %>% 
  filter(
    monitoring_agent_transparency == "not_applicable" & number_agents > 0
  ) %>% 
  mutate(
    i.check.uuid = `_uuid`,
    i.check.today = today,
    i.check.enumerator_id = enumerator_id,
    i.check.identified_issue = "questionable response",
    i.check.type = NA,
    i.check.name = "monitoring_agent_transparency",
    i.check.value = monitoring_agent_transparency,
    i.check.checked_by = "Mathias",
    i.check.checked_date = as_date(today()),
    i.check.comment = NA
  ) %>% 
  select(starts_with("i.check"))%>% 
  rename_with(~gsub("i.check.", "", .x, fixed=TRUE))


# merge checked data ------------------------------------------------------

df_required_after_check <- ls()[grepl(pattern = "df_C_", x = ls() ,  ignore.case=TRUE)]


df_merged_checked_data <- rbind(df_c_charge_each_transfer, df_c_fixed_fee, df_c_monitoring_agent_transparency,
                                df_c_number_agents, df_c_perc_value_delivered, df_c_perc_value_withdraw,          
                                df_c_records_kept, df_c_survey_time, df_c_time_verify_new_agents,       
                                df_c_withdraw_fixed_fee_amount, df_c_yes_operate_presence ) %>% 
  arrange(today, uuid)

write_csv(x = df_merged_checked_data, file = paste0("outputs/pre_cleaning_log_checks_",as_date(today()),"_", hour(now()) ,".csv"), na = "")