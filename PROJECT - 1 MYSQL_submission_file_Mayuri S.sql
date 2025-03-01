-- DATA DRIVEN ANALYTICS TO ENHANCE CUSTOMERS, PRODUCTS AND SALES STRATEGIES --

use modelcarsdb;
select * from modelcarsdb.employees;
select * from customers;
select * from offices;
select * from orderdetails;
select * from orders;
select * from payments;
select * from productlines;
select * from products;

-- TASK - 1 --
-- CUSTOMER DATA ANALYSIS --

-- 1) TOP 10 CUSTOMERS BY CREDIT LIMIT --
select customerNumber, customerName, creditLimit from customers order by creditLimit desc limit 10;
-- Inference: Highest creditLimit is sanctioned to the customer-Euro+shopping channel, customernumber 141

-- 2) AVERAGE CREDIT LIMIT FOR CUSTOMERS IN EACH COUNTRY --
select avg(creditLimit) as avg_credit_limit, country from customers group by country order by avg(creditLimit) desc;
-- Inference: the average creditlimit for customers in Denmark

-- 3) NUMBER OF CUSTOMERS IN EACH STATE --
select state,count(*) as num_of_customers from customers group by state order by count(*) desc;
-- Inference: The count of customers in state CA is the largest

-- 4) CUSTOMERS WHO HAVE NOT PLACED ANY ORDERS --
select c.customerNumber, c.customerName, od.quantityOrdered from customers c left join orders o on c.customerNumber = o.customerNumber 
left join orderdetails od on o.orderNumber = od.orderNumber where od.quantityOrdered is null;
-- Inference: There are 25 customers who have not placed any orders

-- 5) TOTAL SALES OF EACH CUSTOMER --
select c.customerNumber, c.customerName, sum(od.quantityOrdered * od.priceEach) as total_sales from customers c join orders o on o.customerNumber = c.customerNumber 
join orderdetails od on od.orderNumber = o.orderNumber group by c.customerNumber order by sum(od.quantityOrdered * od.priceEach) desc;
-- Inference: The total sales by Euro+shopping channel is the highest

-- 6) CUSTOMERS WITH THEIR ASSIGNED SALES REPRESENTATIVES --
select c.customerNumber, c.customerName, e.firstName, e.lastName, c.salesRepEmployeeNumber from customers c left join employees e on c.salesRepEmployeeNumber = e.EmployeeNumber;

-- 7) CUSTOMER INFORMATION WITH THEIR MOST RECENT PAYMENT DETAILS --
select c.customerNumber, c.customerName, max(paymentDate) as most_recent_pymt_details from customers c join payments p on c.customerNumber = p.customerNumber group by customerNumber;
Select c.customerNumber, c.customerName, p.paymentDate, p.amount from customers c join payments p on c.customerNumber = p.customerNumber 
where p.paymentDate = (select max(paymentDate) from payments where customerNumber = c.customerNumber);

-- 8) CUSTOMERS WHO HAVE EXCEEDED THEIR CREDIT LIMIT --
select c.customerNumber, c.customerName,c.creditLimit, sum(od.quantityOrdered * od.priceEach) as total_purchase, 
(sum(od.quantityOrdered * od.priceEach)-c.creditLimit) as extra_used  from customers c 
join orders o on o.customerNumber = c.customerNumber 
join orderdetails od on od.orderNumber = o.orderNumber 
group by c.customerNumber
having sum(od.quantityOrdered * od.priceEach) > c.creditLimit ;

-- 9) NAMES OF ALL CUSTOMERS WHO HAVE PLACED AN ORDER FOR A PRODUCT FROM A SPECIFIC PRODUCTLINE --
select c.customerNumber, c.customerName, pr.productCode, pr.productLine from customers c join orders o 
on o.customerNumber = c.customerNumber 
join orderdetails od on od.orderNumber = o.orderNumber 
join products pr on pr.productCode = od.productCode
join productlines pl on pr.productLine = pl.productLine;

select c.customerNumber, c.customerName, pr.productCode, pr.productLine from customers c join orders o 
on o.customerNumber = c.customerNumber 
join orderdetails od on od.orderNumber = o.orderNumber 
join products pr on pr.productCode = od.productCode
where pr.productLine = 'Classic Cars';
-- Inference: customer names of specific productline 'classic cars' has been identified

-- 10) NAMES OF ALL CUSTOMERS WHO HAVE PLACED ORDERS FOR THE MOST EXPENSIVE PRODUCTS --
select c.customerNumber, c.customerName, pr.productLine, pr.buyPrice from customers c join orders o 
on o.customerNumber = c.customerNumber 
join orderdetails od on od.orderNumber = o.orderNumber 
join products pr on pr.productCode = od.productCode
where pr.buyPrice= (select max(buyPrice) from products pr where pr.productCode = od.productCode) order by buyPrice desc;
select max(buyPrice) from products;
-- Inference: The max buyPrice is 103.42

-- TASK - 2 --
-- OFFICE DATA ANALYSIS --

select * from employees;
select * from customers;
select * from offices;

-- 1) COUNT OF THE NUMBER OF EMPLOYEES WORKING IN EACH OFFICE --
select officeCode, count(*) as count_of_employees from employees group by officeCode;

-- 2) OFFICES WITH LESS THAN A CERTAIN NUMBER OF EMPLOYEES -- ( I HAVE CONSIDERED THE AVERAGE OF COUNT OF EMPLOYEES IN EACH OFFICE AS THE CERTAIN NUMBER)
select avg(count_of_employees) as avg_count from (select officeCode, count(*) as count_of_employees from employees group by officeCode) as certain_avg_number;
select officeCode, count(*) as count_of_employees from employees group by officeCode having count_of_employees < 3;
-- Inference: offices with less than 2 employees have been identified and the office codes are 2,3,5,7

-- 3) OFFICES ALONG WITH THEIR ASSIGNED TERRITORIES --
select  e.officeCode, off.territory from employees e join offices off on off.officeCode = e.officeCode group by officeCode;

-- 4) OFFICES THAT HAVE NO EMPLOYEES ASIGNED TO THEM --
select off.officeCode, off.city, e.employeeNumber from offices off left join employees e on e.officeCode = off.officeCode where e.employeeNumber is null;
-- Inference: there are no offices with zero employees

-- 5) MOST PROFITABLE OFFICE BASED ON TOTAL SALES --
select e.officeCode, off.city, sum(od.quantityOrdered * od.priceEach) as total_sales from employees e join offices off on e.officeCode = off.officeCode
join customers c on e.employeeNumber= c.salesRepEmployeeNumber
join orders o on c.customerNumber = o.customerNumber
join orderdetails od on o.orderNumber = od.orderNumber group by officeCode order by sum(od.quantityOrdered * od.priceEach) desc limit 1 ;
-- Inference: most profitable office based on sales is officeCode 4 in Paris with total sales of 3083761.58

-- 6) OFFICE WITH THE HIGHEST NUMBER OF EMPLOYEES --
select off.officeCode, count(*) as count_of_employees from employees e join offices off on e.officeCode = off.officeCode group by officeCode order by count(*) desc limit 1;
-- Inference: office code 1 has the highest number of employees: 6

-- 7) AVERAGE CREDIT LIMIT FOR CUSTOMERS IN EACH OFFICE --
select avg(creditLimit) as avg_credit_limit_for_customers,off.city, off.officeCode from employees e join customers c on e.employeeNumber = c.salesRepEmployeeNumber
join offices off on e.officeCode = off.officeCode group by officeCode order by avg_credit_limit_for_customers desc;
-- Inference: average creditlimit for customers in each office and the corresponding city has been identified

-- 8) NUMBER OF OFFICES IN EACH COUNTRY --
select off.country, count(*) as num_of_offices from offices off group by country;
-- Inference: USA has the highest number of offices: 3

-- TASK - 3 --
-- PRODUCT DATA ANALYSIS --

select * from productlines;
select * from products;
select * from orderdetails;
select * from customers;
select * from orders;

-- 1) COUNT OF NUMBER OF PRODUCTS IN EACH PRODUCTLINE --
select pl.productline, count(*) as count_of_products from products pr join productLines pl on pl.productLine = pr.productLine group by productline order by count_of_products desc;
-- -- Inference: classic cars productline has the highest number of products

-- 2)THE PRODUCTLINE WITH THE HIGHEST AVERAGE PRODUCT PRICE --
select pl.productline, avg(buyPrice) as avg_pdt_price from productLines pl join products pr on pl.productLine = pr.productLine  group by pl.productLine order by avg_pdt_price desc limit 1;
select pr.productline, avg(priceEach) as avg_pdt_price from products pr join orderdetails od on pr.productCode = od.productCode group by pr.productLine order by avg_pdt_price desc limit 1;
-- Inference: The productline with the highest average product price is classic cars

-- 3) PRODUCTS WITH MSRP BETWEEN 50 AND 100
select pr.productCode, pr.productName, pr.productLine, pr.MSRP from products pr where pr.MSRP between '50' and '100'order by pr.MSRP asc;

-- 4) TOTAL SALES AMOUNT FOR EACH PRODUCLINE --
select pr.productLine, sum(od.quantityOrdered * od.priceEach) as total_sales from products pr join orderdetails od on pr.productCode = od.productCode group by productLine;

-- 5) PRODUCTS WITH LOW INVENTORY LEVELS WHERE THE quantityInStock IS LESS THAN 100 --
select productLine, productName, quantityInStock from products where quantityInStock < 10;
select productLine, productName, quantityInStock from products where quantityInStock < 100;
-- Inference: there are no products with quantity in stock less than 10 and 2 products with quantity in stock less than 100

-- 6) THE MOST EXPENSIVE PRODUCT BASED ON MSRP --
select productLine, max(MSRP) from products group by productLine order by max(MSRP) desc limit 1 ;
select productLine,productCode, productName, MSRP from products order by  MSRP desc limit 1;
-- Inference: The most expensive product based on MSRP is classic cars

-- 7) TOTAL SALES FOR EACH PRODUCT --
select pr.productCode,pr.productName, sum(od.quantityOrdered * od.priceEach) as total_sales from products pr join orderdetails od on pr.productCode = od.productCode group by pr.productCode;

-- 8) TOP SELLING PRODUCTS BASED ON TOTAL QUANTITY ORDERED USING A STORED PROCEDURE --
DELIMITER //
CREATE PROCEDURE top_selling_products (in no_of_products int)
BEGIN
Select pr.productCode, pr.productName, SUM(od.quantityOrdered) as total_quantity
from products pr join orderdetails od on pr.productCode = od.productCode
group by pr.productCode
order by total_quantity desc limit 10;
END //
call top_selling_products(10);
-- Inference: The top most selling product is 1992 Ferrari 360 Spider end

-- 9) PRODUCTS WITH LOW INVENTORY LEVELS OF LESS THAN 10 WITHIN SPECIFIC PRODUCTLINES --
select productLine, productName, quantityInStock from products where productLine in ('Classic Cars','Motorcycles') and quantityInStock <10;
select productLine, productName, quantityInStock from products where productLine = 'Motorcycles' and quantityInStock <100;
-- Inference: there is no productline line with quantity less than 10

-- 10) NAMES OF ALL PRODUCTS THAT HAVE BEEN ORDERED BY MORE THAN 10 CUSTOMERS --
select * from orderdetails;
select  pr.productCode,pr.productName, count(orderNumber) as orders_placed from products pr join orderdetails od on pr.productCode = od.productCode 
group by pr.productCode order by orders_placed > 10 ;

-- 11) NAMES OF ALL PRODUCTS THAT HAVE BEEN ORDERED MORE THAN THE AVERAGE NUMBER OF ORDERS FOR THEIR PRODUCTLINE --
 select pr.productName,orders_more_than_avg from products pr join (select pr.productLine, count(orderNumber) as orders_more_than_avg from products pr join orderdetails od on pr.productCode = od.productCode 
group by pr.productLine having count(orderNumber)>428.000)as r;

-- Inference: names of all products that have been ordered more than the average number of orders of their productline(428) have been identified

select avg(orders_placed) as avg_order from (select pr.productLine, count(orderNumber) as orders_placed from products pr join orderdetails od on pr.productCode = od.productCode 
group by productLine)as t;

----------------------------- ********************** TASKS COMPLETED ********************** ------------------------------