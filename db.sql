create database test7;

use test7;

create table consumer_port(
    port_id int primary key,
    password varchar(255) not null, 
    role varchar(255) not null,
    location varchar(255) not null
);

desc consumer_port;

create table seller_port(
    port_id int primary key,
    password varchar(255) not null,
    role varchar(255) not null,
    location varchar(255)
);

desc seller_port;

-- ensure password column can store hashed values
alter table
    consumer_port
modify
    password varchar(255);

alter table
    seller_port
modify
    password varchar(255);

create table backup_consumer(
    port_id int,
    operation_type enum('insert', 'update', 'delete') not null,
    password varchar(255),
    role varchar(255),
    location varchar(255)
);

create table backup_seller(
    port_id int,
    operation_type enum('insert', 'update', 'delete') not null,
    password varchar(255),
    role varchar(255),
    location varchar(255)
);

create table product (
    product_id int primary key,
    product_name varchar(100) not null,
    product_price decimal(10, 2) not null,
    product_quantity int not null,
    seller_id int,
    constraint fk_seller foreign key (seller_id) references seller_port(port_id) on delete cascade
);

-- table: product_backup
create table product_backup(
    product_id int,
    operationtype enum('insert', 'update', 'delete') not null,
    product_name varchar(250) not null,
    product_price decimal(10, 2) not null,
    product_quantity int not null,
    seller_id int
);

create table orders (
    order_id int not null,
    consumer_port_id int not null,
    product_id int not null,
    product_quantity int not null,
    order_date datetime not null,
    order_placed boolean not null,
    shipped boolean not null,
    out_for_delivery boolean not null,
    delivered boolean not null,
    primary key (order_id, product_id),
    -- composite primary key
    foreign key (consumer_port_id) references consumer_port(port_id) on delete cascade,
    foreign key (product_id) references product(product_id) on delete cascade
);

-- backup table for orders
create table backup_orders (
    backup_id int primary key auto_increment,
    order_id int,
    consumer_port_id int,
    product_id int,
    product_quantity int,
    order_date datetime,
    order_placed boolean not null,
    shipped boolean not null,
    out_for_delivery boolean not null,
    delivered boolean not null
);


create table reported_product (
    report_id int primary key auto_increment,
    consumer_port_id int not null,
    product_id int not null,
    issue_type enum(
        'damage',
        'wrong product',
        'delayed',
        'not received',
        'missing'
    ) not null,
    solution varchar(255),
    report_date datetime not null,
    token varchar(255) unique not null,
    status enum('pending', 'resolved') default 'pending',
    foreign key (consumer_port_id) references consumer_port(port_id) on delete cascade,
    foreign key (product_id) references product(product_id) on delete cascade
);

-- table: backup_reported_product
create table backup_reported_product (
    backup_id int primary key auto_increment,
    operationtype enum('insert', 'update', 'delete') not null,
    report_id int,
    consumer_port_id int,
    product_id int,
    issue_type enum(
        'damage',
        'wrong product',
        'delayed',
        'not received',
        'missing'
    ),
    solution varchar(255),
    report_date datetime,
    token varchar(255),
    status enum('pending', 'resolved')
);

delimiter & & create trigger backup_consumer
after
insert
    on consumer_port for each row begin
insert into
    backup_consumer
values
(new.port_id, new.password, new.role, new.location);

end & & delimiter;

delimiter & & create trigger update_consumer before
update
    on consumer_port for each row begin
insert into
    consumer_backup(port_id, password, role, location)
values
(
        old.port_id,
        old.password,
        old.role,
        old.location
    );

end & & create trigger delete_consumer before delete on consumer_port for each row begin
insert into
    consumer_backup(port_id, password, role, location)
values
(
        old.port_id,
        old.password,
        old.role,
        old.location
    );
    

end & & delimiter;


desc consumer_port;
-- consumer login page
delimiter & & -- seller backup

delimiter & & create trigger backup_seller
after
insert
    on seller_port for each row begin
insert into
    backup_seller
values
(new.port_id, new.password, new.role, new.location);

end & & delimiter;

delimiter & & create trigger update_seller before
update
    on seller_port for each row begin
insert into
    seller_backup(port_id, password, role, location)
values
(
        old.port_id,
        old.password,
        old.role,
        old.location
    );

end & & create trigger delete_seller before delete on seller_port for each row begin
insert into
    seller_backup(port_id, password, role, location)
values
(
        old.port_id,
        old.password,
        old.role,
        old.location
    );

end & & delimiter;

-- hrithik
-- table: product

delimiter & & -- trigger for product_backup
--  the insert trigger
delimiter & & create trigger product_backup_trigger
after
insert
    on product for each row begin
insert into
    product_backup(
        operationtype,
        product_id,
        product_name,
        product_price,
        product_quantity,
        seller_id
    )
values
(
        'insert',
        new.product_id,
        new.product_name,
        new.product_price,
        new.product_quantity,
        new.seller_id
    );

end & & -- the update trigger
create trigger product_update_trigger before
update
    on product for each row begin
insert into
    product_backup(
        operationtype,
        product_id,
        product_name,
        product_price,
        product_quantity,
        seller_id
    )
values
(
        'update',
        old.product_id,
        old.product_name,
        old.product_price,
        old.product_quantity,
        old.seller_id
    );

end & & --  the delete trigger
create trigger product_delete_trigger before delete on product for each row begin
insert into
    product_backup(
        operationtype,
        product_id,
        product_name,
        product_price,
        product_quantity,
        seller_id
    )
values
(
        'delete',
        old.product_id,
        old.product_name,
        old.product_price,
        old.product_quantity,
        old.seller_id
    );

end & & delimiter;

delimiter & & -- stored procedure for add_product

-- view seller products
create view seller_products as
select
    p.product_id,
    -- from product table
    p.product_name,
    -- from product table
    p.product_price,
    -- from product table
    p.product_quantity,
    -- from product table
    p.seller_id,
    -- from product table
    s.role as seller_role,
    -- from seller_port table (renamed for clarity)
    s.location as seller_location -- from seller_port table (renamed for clarity)
from
    product p
    join seller_port s on p.seller_id = s.port_id;

-- yash
-- table: orders

-- trigger for orders backup
delimiter & & create trigger backup_orders_trigger
after
insert
    on orders for each row begin
insert into
    backup_orders (
        order_id,
        consumer_port_id,
        product_id,
        product_quantity,
        order_date,
        order_placed,
        shipped,
        out_for_delivery,
        delivered
    )
values
    (
        new.order_id,
        new.consumer_port_id,
        new.product_id,
        new.product_quantity,
        new.order_date,
        new.order_placed,
        new.shipped,
        new.out_for_delivery,
        new.delivered
    );

end;

& & create trigger update_orders_trigger before
update
    on orders for each row begin
insert into
    backup_orders (
        order_id,
        consumer_port_id,
        product_id,
        product_quantity,
        order_date,
        order_placed,
        shipped,
        out_for_delivery,
        delivered
    )
values
    (
        old.order_id,
        old.consumer_port_id,
        old.product_id,
        old.product_quantity,
        old.order_date,
        old.order_placed,
        old.shipped,
        old.out_for_delivery,
        old.delivered
    );

end;

& & create trigger delete_orders_trigger before delete on orders for each row begin
insert into
    backup_orders (
        order_id,
        consumer_port_id,
        product_id,
        product_quantity,
        order_date,
        order_placed,
        shipped,
        out_for_delivery,
        delivered
    )
values
    (
        old.order_id,
        old.consumer_port_id,
        old.product_id,
        old.product_quantity,
        old.order_date,
        old.order_placed,
        old.shipped,
        old.out_for_delivery,
        old.delivered
    );

end;

& & delimiter;

-- purva
-- table: reported_product

-- function: generate_token
delimiter & & create function generate_token() returns varchar(255) deterministic begin declare token varchar(255);

set
    token = uuid();

return token;

end & & delimiter;

-- register user procedure with password hashing
delimiter & & create procedure register_user(
    uportid int,
    upass varchar(255),
    uconformpass varchar(255),
    urole varchar(255),
    ulocation varchar(255)
) begin if upass = uconformpass then if urole = 'consumer' then
insert into
    consumer_port (port_id, password, role, location)
values
    (uportid, sha2(upass, 256), urole, ulocation);

select
    'consumer registered successfully' as message;

else
insert into
    seller_port (port_id, password, role, location)
values
    (uportid, sha2(upass, 256), urole, ulocation);

select
    'seller registered successfully' as message;

end if;

else
select
    'password does not match' as message;

end if;

end & & delimiter;

-- consumer login procedure with password hashing
delimiter & & create procedure consumer_login(uportid int, upass varchar(255)) begin declare db_password varchar(255);

-- retrieve the stored hashed password
select
    password into db_password
from
    consumer_port
where
    port_id = uportid;

-- if the consumer exists, compare hashed password
if db_password is not null
and db_password = sha2(upass, 256) then
select
    'consumer login successful' as message;

else
select
    'invalid credentials' as message;

end if;

end & & delimiter;

-- seller login procedure with password hashing
delimiter & & create procedure seller_login_secure(
    p_port_id int,
    p_password varchar(255)
) begin declare db_password varchar(255);

-- retrieve the stored hashed password
select
    password into db_password
from
    seller_port
where
    port_id = p_port_id;

-- if the seller exists, compare hashed password
if db_password is not null
and db_password = sha2(p_password, 256) then
select
    'seller login successful' as message;

else
select
    'invalid credentials' as message;

end if;

end & & delimiter;

-- update profile consumer--
-- procedure to manage consumer operations (insert, update, delete) 
delimiter & & create procedure consumer(
    in operation_type enum('insert', 'update', 'delete'),
    in p_port_id int,
    in p_password varchar(255),
    in p_role varchar(255),
    in p_location varchar(255)
) begin if operation_type = 'insert' then
insert into
    consumer_port (port_id, password, role, location)
values
    (p_port_id, p_password, p_role, p_location);

select
    'consumer inserted successfully' as message;

elseif operation_type = 'update' then
update
    consumer_port
set
    password = p_password,
    role = p_role,
    location = p_location
where
    port_id = p_port_id;

select
    'consumer updated successfully' as message;

elseif operation_type = 'delete' then
delete from
    consumer_port
where
    port_id = p_port_id;

select
    'consumer deleted successfully' as message;

else signal sqlstate '45000'
set
    message_text = 'invalid operation type';

end if;

end & & delimiter;

-- update profile seller-- 
-- procedure to manage seller operations (insert, update, delete)
delimiter & & create procedure seller(
    in action_type enum('insert', 'update', 'delete'),
    in p_port_id int,
    in p_password varchar(255),
    in p_role varchar(255),
    in p_location varchar(255)
) begin if action_type = 'insert' then
insert into
    seller_port (port_id, password, role, location)
values
    (p_port_id, p_password, p_role, p_location);

select
    'seller inserted successfully' as message;

elseif action_type = 'update' then
update
    seller_port
set
    password = p_password,
    role = p_role,
    location = p_location
where
    port_id = p_port_id;

select
    'seller updated successfully' as message;

elseif action_type = 'delete' then
delete from
    seller_port
where
    port_id = p_port_id;

select
    'seller deleted successfully' as message;

else signal sqlstate '45000'
set
    message_text = 'invalid action type';

end if;

end & & delimiter;

procedure for search --
delimiter & & create procedure search_product(
    in search_term varchar(100),
    in min_price decimal(10, 2),
    in max_price decimal(10, 2),
    in search_seller_id int
) begin
select
    *
from
    product
where
    (
        product_name like concat('%', search_term, '%')
        or search_term is null
    )
    and (
        product_price between min_price
        and max_price
        or min_price is null
        or max_price is null
    )
    and (
        seller_id = search_seller_id
        or search_seller_id is null
    );

end & & delimiter;

create procedure add_product(
    in p_id int,
    in p_name varchar(100),
    in p_price decimal(10, 2),
    in p_quantity int,
    in p_seller_id int
) begin if p_price <= 0
or p_quantity <= 0 then signal sqlstate '45000'
set
    message_text = 'invalid price or quantity';

else
insert into
    product (
        product_id,
        product_name,
        product_price,
        product_quantity,
        seller_id
    )
values
    (p_id, p_name, p_price, p_quantity, p_seller_id);

end if;

end & & delimiter;

delimiter & & -- hritik 
-- procedure for upadte_product
create procedure update_product(
    in p_product_id int,
    in p_product_name varchar(100),
    in p_product_price decimal(10, 2),
    in p_product_quantity int,
    in p_seller_id int
) begin -- check if the product exists
if not exists (
    select
        1
    from
        product
    where
        product_id = p_product_id
) then signal sqlstate '45000'
set
    message_text = 'product does not exist';

end if;

-- check if the seller exists (if seller_id is provided)
if p_seller_id is not null
and not exists (
    select
        1
    from
        seller_port
    where
        port_id = p_seller_id
) then signal sqlstate '45000'
set
    message_text = 'seller does not exist';

end if;

-- validate price and quantity
if p_product_price <= 0
or p_product_quantity <= 0 then signal sqlstate '45000'
set
    message_text = 'invalid price or quantity';

end if;

-- update the product
update
    product
set
    product_name = p_product_name,
    product_price = p_product_price,
    product_quantity = p_product_quantity,
    seller_id = p_seller_id
where
    product_id = p_product_id;

select
    'product updated successfully' as message;

end & & -- procedure for delete_product
delimiter & & create procedure delete_product(in p_product_id int) begin -- check if the product exists
if not exists (
    select
        1
    from
        product
    where
        product_id = p_product_id
) then signal sqlstate '45000'
set
    message_text = 'product does not exist';

end if;

-- delete the product
delete from
    product
where
    product_id = p_product_id;

select
    'product deleted successfully' as message;

end & & delimiter;

-- yash procedures--
-- procedure for adding product into orders tables
delimiter & & create procedure place_order(
    in p_order_id int,
    in p_consumer_port_id int
) begin declare v_product_id int;

declare v_quantity int;

declare v_finished int default 0;

-- cursor to fetch products from the cart
declare cart_cursor cursor for
select
    product_id,
    quantity
from
    cart
where
    consumer_port_id = p_consumer_port_id;

-- handler for when no more rows are found
declare continue handler for not found
set
    v_finished = 1;

-- check if the consumer exists
if not exists (
    select
        1
    from
        consumer_port
    where
        port_id = p_consumer_port_id
) then signal sqlstate '45000'
set
    message_text = 'consumer does not exist';

end if;

-- open the cursor
open cart_cursor;

-- loop through the cart items
cart_loop: loop fetch cart_cursor into v_product_id,
v_quantity;

-- exit the loop if no more rows
if v_finished = 1 then leave cart_loop;

end if;

-- check if the product has sufficient quantity
if (
    select
        quantity
    from
        product
    where
        product_id = v_product_id
) < v_quantity then signal sqlstate '45000'
set
    message_text = 'insufficient product quantity';

end if;

-- insert the product into the orders table
insert into
    orders (
        order_id,
        consumer_port_id,
        product_id,
        product_quantity,
        order_date,
        order_placed,
        shipped,
        out_for_delivery,
        delivered
    )
values
    (
        p_order_id,
        p_consumer_port_id,
        v_product_id,
        v_quantity,
        now(),
        true,
        false,
        false,
        false
    );

-- update the product quantity in the products table
update
    product
set
    quantity = quantity - v_quantity
where
    product_id = v_product_id;

end loop;

-- close the cursor
close cart_cursor;

-- clear the cart for the consumer
delete from
    cart
where
    consumer_port_id = p_consumer_port_id;

-- return success message
select
    'order placed successfully!' as message;

end & & delimiter;

delimiter & & create procedure cancel_order(
    in p_order_id int,
    in p_consumer_port_id int
) begin -- check if the order exists and isn't shipped yet
if not exists (
    select
        1
    from
        orders
    where
        order_id = p_order_id
        and consumer_port_id = p_consumer_port_id
        and shipped = false
) then signal sqlstate '45000'
set
    message_text = 'order cannot be canceled';

end if;

-- update the order_placed column to false (marking it as canceled)
update
    orders
set
    order_placed = false
where
    order_id = p_order_id
    and consumer_port_id = p_consumer_port_id;

select
    'order canceled successfully!' as message;

end & & delimiter;

delimiter & & -- procedure: add_to_cart
delimiter & & create procedure add_to_cart(
    in p_consumer_port_id int,
    in p_product_id int,
    in p_quantity int
) begin -- check if the consumer exists
if not exists (
    select
        1
    from
        consumer_port
    where
        port_id = p_consumer_port_id
) then signal sqlstate '45000'
set
    message_text = 'consumer does not exist';

end if;

-- check if the product exists
if not exists (
    select
        1
    from
        product
    where
        product_id = p_product_id
) then signal sqlstate '45000'
set
    message_text = 'product does not exist';

end if;

-- check if the product has sufficient quantity
if (
    select
        quantity
    from
        product
    where
        product_id = p_product_id
) < p_quantity then signal sqlstate '45000'
set
    message_text = 'insufficient product quantity';

end if;

-- insert the product into the cart
insert into
    cart (
        consumer_port_id,
        product_id,
        quantity,
        added_date
    )
values
    (
        p_consumer_port_id,
        p_product_id,
        p_quantity,
        now()
    );

-- return success message
select
    'product added to cart successfully!' as message;

end & & delimiter;

delimiter & & create procedure track_order(
    in p_order_id int,
    in p_shipped boolean,
    in p_out_for_delivery boolean,
    in p_delivered boolean
) begin
update
    orders
set
    shipped = p_shipped,
    out_for_delivery = p_out_for_delivery,
    delivered = p_delivered
where
    order_id = p_order_id;

select
    'order status updated successfully for all products in the order!' as message;

end & & delimiter;

delimiter & & create procedure add_to_wishlist(
    in p_consumer_port_id int,
    in p_product_id int
) begin -- check if the consumer exists
if not exists (
    select
        1
    from
        consumer_port
    where
        port_id = p_consumer_port_id
) then signal sqlstate '45000'
set
    message_text = 'consumer does not exist';

end if;

-- check if the product exists
if not exists (
    select
        1
    from
        product
    where
        product_id = p_product_id
) then signal sqlstate '45000'
set
    message_text = 'product does not exist';

end if;

-- insert the product into the wishlist
insert into
    wishlist (consumer_port_id, product_id, added_date)
values
    (p_consumer_port_id, p_product_id, now());

-- return success message
select
    'product added to wishlist successfully!' as message;

end & & delimiter;

delimiter & & create procedure move_from_wishlist_to_cart(
    in p_consumer_port_id int,
    in p_product_id int,
    in p_quantity int
) begin -- check if the product is in the wishlist
if not exists (
    select
        1
    from
        wishlist
    where
        consumer_port_id = p_consumer_port_id
        and product_id = p_product_id
) then signal sqlstate '45000'
set
    message_text = 'product not found in wishlist';

end if;

-- check if the product has sufficient quantity
if (
    select
        quantity
    from
        product
    where
        product_id = p_product_id
) < p_quantity then signal sqlstate '45000'
set
    message_text = 'insufficient product quantity';

end if;

-- add the product to the cart
insert into
    cart (
        consumer_port_id,
        product_id,
        quantity,
        added_date
    )
values
    (
        p_consumer_port_id,
        p_product_id,
        p_quantity,
        now()
    );

-- remove the product from the wishlist after adding it to the cart
delete from
    wishlist
where
    consumer_port_id = p_consumer_port_id
    and product_id = p_product_id;

-- return success message
select
    'product moved from wishlist to cart successfully!' as message;

end & & delimiter;

-- procedure for reported products--
-- procedure: add_report
DELIMITER $$

CREATE PROCEDURE add_report(
    IN p_consumer_port_id INT,
    IN p_product_id INT,
    IN p_issue_type ENUM('damage', 'wrong product', 'delayed', 'not received', 'missing'),
    IN p_report_date DATETIME
)
BEGIN
    DECLARE v_token VARCHAR(255);
    DECLARE v_solution VARCHAR(255);

    -- Check if the consumer has ordered the product
    IF NOT EXISTS (
        SELECT 1
        FROM orders
        WHERE consumer_port_id = p_consumer_port_id
        AND product_id = p_product_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Consumer has not ordered this product';
    END IF;

    -- Generate a unique token
    SET v_token = UUID();  -- Using UUID() to generate a unique token

    -- Propose solutions based on the issue type
    CASE p_issue_type
        WHEN 'damage' THEN
            SET v_solution = 'replacement';
        WHEN 'wrong product' THEN
            SET v_solution = 'replacement';
        WHEN 'delayed' THEN
            SET v_solution = 'compensation';
        WHEN 'not received' THEN
            SET v_solution = 'resend';
        WHEN 'missing' THEN
            SET v_solution = 'resend';
        ELSE
            SET v_solution = 'investigation required';
    END CASE;

    -- Insert the report into the reports table
    INSERT INTO reports (consumer_port_id, product_id, issue_type, report_date, token, solution)
    VALUES (p_consumer_port_id, p_product_id, p_issue_type, p_report_date, v_token, v_solution);

    -- Return the token and solution
    SELECT v_token AS token, v_solution AS solution;
END$$

DELIMITER ;

-- procedure: view_reports
delimiter & & create procedure view_reports() begin
select
    report_id,
    consumer_port_id,
    product_id,
    issue_type,
    solution,
    report_date,
    token,
    status
from
    reported_product;

end & & delimiter;

-- procedure: resolve_report
delimiter & & create procedure resolve_report(p_report_id int) begin
update
    reported_product
set
    status = 'resolved'
where
    report_id = p_report_id;

select
    'report resolved successfully' as message;

end & & delimiter;

DELIMITER $$

CREATE TRIGGER after_reported_product_insert
AFTER INSERT ON reported_product
FOR EACH ROW
BEGIN
    DECLARE v_solution VARCHAR(255);

    -- Propose solutions based on the issue type
    CASE NEW.issue_type
        WHEN 'damage' THEN
            SET v_solution = 'replacement';
        WHEN 'wrong product' THEN
            SET v_solution = 'replacement';
        WHEN 'delayed' THEN
            SET v_solution = 'compensation';
        WHEN 'not received' THEN
            SET v_solution = 'resend';
        WHEN 'missing' THEN
            SET v_solution = 'resend';
        ELSE
            SET v_solution = 'investigation required';
    END CASE;

    -- Update the reported_product table with the proposed solution
    UPDATE reported_product
    SET solution = v_solution
    WHERE report_id = NEW.report_id;
END $$

DELIMITER ;

-- Procedure to add a product to the cart (in the orders table)
DELIMITER //

CREATE PROCEDURE AddToCart(
IN p_consumer_id INT,
IN p_product_id INT,
IN p_quantity INT
)
BEGIN
DECLARE v_stock INT;
DECLARE v_price DECIMAL(10,2);
DECLARE v_existing_quantity INT;

SELECT product_quantity INTO v_existing_quantity
FROM orders
WHERE consumer_port_id = p_consumer_id AND product_id = p_product_id AND order_placed = FALSE;

IF v_existing_quantity IS NOT NULL THEN
UPDATE orders
SET product_quantity = product_quantity + p_quantity
WHERE consumer_port_id = p_consumer_id AND product_id = p_product_id AND order_placed = FALSE;
ELSE
INSERT INTO orders (order_date, order_placed, shipped, out_for_delivery, delivered, quantity, product_id, consumer_port_id)
VALUES (CURDATE(), FALSE, FALSE, FALSE, FALSE, p_quantity, p_product_id, p_consumer_id);

SELECT 'Product added to the cart.' AS Message;
END IF;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE RemoveFromCart(
IN p_consumer_id INT,
IN p_product_id INT
)
BEGIN
DELETE FROM orders
WHERE consumer_port_id = p_consumer_id AND product_id = p_product_id AND order_placed = FALSE;

SELECT 'Product removed from cart.' AS Message;
END //

DELIMITER ;

-- View Cart Items (New Procedure)
DELIMITER //

CREATE PROCEDURE ViewCartItems(IN consumerID INT)
BEGIN

SELECT
p.product_id,
p.product_name,
o.product_quantity,
p.product_price,
(o.product_quantity * p.product_price) AS subtotal
FROM orders o
JOIN product p ON o.product_id = p.product_id
WHERE o.consumer_port_id = consumerID AND o.order_placed = FALSE;

SELECT SUM(o.product_quantity * p.product_price) AS total_price
FROM orders o
JOIN product p ON o.product_id = p.product_id
WHERE o.consumer_port_id = consumerID AND o.order_placed = FALSE;

END //

DELIMITER ;
