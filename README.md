# campaigns_analysis
**Objective:** Compare KPIs before and after starting campaigns and the most successful campaigns. 
## Project Overview
Running campaigns can be a key strategy for stakeholders to achieve their goals. Effective campaigns have the potential to attract more customers, and when executed properly, they can boost a company’s profitability and efficiency. To evaluate campaign performance, various Key Performance Indicators (KPIs) can be applied based on the company’s objectives. In this project, six KPIs are analyzed using nearly two years of transaction data from a retail business with 2,500 households. These KPIs are then used to rank the campaigns and determine which one was the most successful.

## Dataset Description
The datasets are obtained from [the Dunnhumby website (the complete Journey)](https://www.dunnhumby.com/source-files/), which is the first data science customer in the world. In this project, 4 tables are used, which are described as follows.

### transaction_data
Transaction data shows all products purchased by households within the dataset. Each row is essentially the same line that would be found on a store receipt. It is worth mentioning that sales_value in this table is the amount of dollars received by the retailer on the sale of the specific product, not the actual price paid by the customer. Below is the description of all variables in this table.
| Variable             | Description                                                        |
|----------------------|--------------------------------------------------------------------|
| `household_key`      | Uniquely identifies each household                                 |
| `basket_id`          | Uniquely identifies a purchase occasion                            |
| `day`                | Day when transaction occurred                                      |
| `product_id`         | Uniquely identifies each product                                   |
| `quantity`           | Number of the products purchased during the trip                   |
| `sales_value`        | Amount of dollars retailer receives from the sale                  |
| `store_id`           | Identifies unique stores                                           |
| `coupon_match_disc`  | Discount applied due to retailer’s match                           |
| `coupon_disc`        | Discount applied due to manufacturer coupon                        |
| `retail_disc`        | Discount applied due to retailer’s loyalty card programme          |
| `trans_time`         | Time of day when transaction occurred                              |
| `week_no`            | Week of the transaction. Ranges from 1 to 102                      |
