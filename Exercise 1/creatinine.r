library(mosaic)
library(tinyverse)

plot(creatclear ~ age, data = creatinine)

lm1 = lm(creatclear ~ age, data = creatinine)

new_data = data.frame(age = c(40, 55, 60))
l = predict(lm1, new_data)
l[2]

# 1. We should expect a creatinine clearance rate of
#    113.723 mL/minute for the average 55 year-old.

coef(lm1)

# 2. The rate at which the creatinine clearance rate
#    changes is about -0.620 mL/minute each year one
#    gets older.

135 - l[1]
112 - l[3]

# 3. The creatinine clearance rate of the 40 year-old
#    is healthier as it is 11.980 mL/minute above the
#    average while it is 1.376 mL/minute for the 60
#    year-old. 