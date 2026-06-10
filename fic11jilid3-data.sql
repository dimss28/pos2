-- Data-only import for POS (run AFTER: php artisan migrate:fresh --force)
-- Tables must already exist from Laravel migrations.

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE `order_items`;
TRUNCATE TABLE `orders`;
TRUNCATE TABLE `cash_sessions`;
TRUNCATE TABLE `personal_access_tokens`;
TRUNCATE TABLE `products`;
TRUNCATE TABLE `categories`;
TRUNCATE TABLE `users`;

INSERT INTO `users` (`id`, `name`, `email`, `phone`, `avatar`, `is_active`, `deleted_at`, `last_login_at`, `last_login_ip`, `roles`, `email_verified_at`, `password`, `two_factor_secret`, `two_factor_recovery_codes`, `two_factor_confirmed_at`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Code with Bahri', 'bahri@fic11.com', '681-549-9977', NULL, 1, NULL, '2026-06-07 07:56:46', '192.168.18.202', 'owner', '2026-06-07 01:35:46', '$2y$12$h8mlVWspXBvEPo9asqmyUO8qMfg2ECxR3e.eRvTI7XdQ6rGVr5kuy', NULL, NULL, NULL, 'y4JG4zWl5d', '2026-06-07 01:35:47', '2026-06-07 07:56:46'),
(2, 'Admin Cafe', 'admin@fic11.com', '+14053945920', NULL, 1, NULL, NULL, NULL, 'admin', '2026-06-07 01:35:47', '$2y$12$DUZBHMHTdtBcn6.61te5c.HkxQh7G54m/MWIve7Nv1Ma0g9pzRnuq', NULL, NULL, NULL, 'xUSU3hVjrP', '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(3, 'Cruz Ryan', 'lreichel@example.org', '1-808-233-6689', NULL, 1, NULL, NULL, NULL, 'kasir', '2026-06-07 01:35:47', '$2y$12$T6i8k5DK7.qNcELK7m8QxOKTmKCMzv8g4k/1XN.1hPV2U2mBgXbWe', NULL, NULL, NULL, 'hCjW7TcUqk', '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(4, 'Dr. Madisyn Weimann', 'tatum46@example.com', '+1-717-731-8259', NULL, 1, NULL, NULL, NULL, 'kasir', '2026-06-07 01:35:47', '$2y$12$T6i8k5DK7.qNcELK7m8QxOKTmKCMzv8g4k/1XN.1hPV2U2mBgXbWe', NULL, NULL, NULL, 'OCBP89ECCJ', '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(5, 'Angelica Roob', 'cassidy.trantow@example.com', '+1-872-648-9533', NULL, 1, NULL, NULL, NULL, 'kasir', '2026-06-07 01:35:47', '$2y$12$T6i8k5DK7.qNcELK7m8QxOKTmKCMzv8g4k/1XN.1hPV2U2mBgXbWe', NULL, NULL, NULL, 'UdkEJWzTvQ', '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(6, 'Mylene Kuphal', 'lubowitz.gudrun@example.org', '212.626.3209', NULL, 1, NULL, NULL, NULL, 'kasir', '2026-06-07 01:35:47', '$2y$12$T6i8k5DK7.qNcELK7m8QxOKTmKCMzv8g4k/1XN.1hPV2U2mBgXbWe', NULL, NULL, NULL, 'ymv06oUvXJ', '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(7, 'Mr. Broderick Hirthe', 'skye.kassulke@example.com', '(469) 828-4331', NULL, 1, NULL, NULL, NULL, 'kasir', '2026-06-07 01:35:47', '$2y$12$T6i8k5DK7.qNcELK7m8QxOKTmKCMzv8g4k/1XN.1hPV2U2mBgXbWe', NULL, NULL, NULL, '6p8HFUZGOa', '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(8, 'Arianna Wyman', 'fdibbert@example.org', '(341) 495-9143', NULL, 1, NULL, NULL, NULL, 'kasir', '2026-06-07 01:35:47', '$2y$12$T6i8k5DK7.qNcELK7m8QxOKTmKCMzv8g4k/1XN.1hPV2U2mBgXbWe', NULL, NULL, NULL, 'NAwWNaBry6', '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(9, 'Prof. Darrick Stoltenberg', 'trycia70@example.net', '248.974.6407', NULL, 1, NULL, NULL, NULL, 'kasir', '2026-06-07 01:35:47', '$2y$12$T6i8k5DK7.qNcELK7m8QxOKTmKCMzv8g4k/1XN.1hPV2U2mBgXbWe', NULL, NULL, NULL, 'gWBReFtwhJ', '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(10, 'Dr. Keagan Feeney DDS', 'raleigh.mccullough@example.com', '+1-586-347-1297', NULL, 1, NULL, NULL, NULL, 'kasir', '2026-06-07 01:35:47', '$2y$12$T6i8k5DK7.qNcELK7m8QxOKTmKCMzv8g4k/1XN.1hPV2U2mBgXbWe', NULL, NULL, NULL, '75h4ICAGag', '2026-06-07 01:35:47', '2026-06-07 01:35:47');

INSERT INTO `categories` (`id`, `name`, `slug`, `description`, `icon`, `color`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Makanan', 'makanan', NULL, 'cube', '#F59E0B', 0, 1, '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(2, 'Minuman', 'minuman', NULL, 'coffee', '#3B82F6', 1, 1, '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(3, 'Snack', 'snack', NULL, 'gift', '#10B981', 2, 1, '2026-06-07 01:35:47', '2026-06-07 01:35:47'),
(4, 'Dessert', 'dessert', NULL, 'cake', '#EC4899', 3, 1, '2026-06-07 01:35:47', '2026-06-07 01:35:47');

INSERT INTO `products` (`id`, `name`, `description`, `price`, `stock`, `category`, `image`, `created_at`, `updated_at`, `is_best_seller`, `category_id`) VALUES
(1, 'Linnea Lesch', 'Error similique laudantium ad et debitis qui. Enim maiores et nesciunt mollitia maiores. Repellat non in qui.', 81493, 49, 'snack', 'https://via.placeholder.com/640x480.png/006699?text=in', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(2, 'Brionna Barrows', 'Quia sequi in ut assumenda reprehenderit. Unde nobis numquam expedita aut quo ratione nostrum. Aut omnis voluptas iure atque maiores excepturi.', 65475, 84, 'food', 'https://via.placeholder.com/640x480.png/008855?text=praesentium', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(3, 'Brianne Morissette', 'Asperiores accusamus officia occaecati id sed. Voluptatum occaecati repudiandae quia molestiae. Debitis reprehenderit blanditiis maiores assumenda omnis.', 89840, 64, 'food', 'https://via.placeholder.com/640x480.png/005511?text=sed', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(4, 'Dr. Delfina Hoppe Sr.', 'Atque maxime eligendi et ipsum enim. Mollitia error corporis dolorum delectus eaque officiis impedit. Nemo et voluptas quis labore enim sed. Occaecati est placeat sed consequatur.', 53083, 100, 'snack', 'https://via.placeholder.com/640x480.png/003399?text=quae', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(5, 'Dr. Dawson Weimann IV', 'Quibusdam architecto harum ut occaecati est ut. Et sed atque eum doloremque error et. Quae molestias maxime non earum doloremque.', 25682, 95, 'food', 'https://via.placeholder.com/640x480.png/004433?text=repellat', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(6, 'Prof. Geoffrey Crona III', 'Sit ex quia temporibus quisquam. Et minus enim laudantium blanditiis cupiditate molestias. Id aut magni aspernatur dolorem voluptate est eveniet.', 43003, 83, 'food', 'https://via.placeholder.com/640x480.png/00dd33?text=et', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(7, 'Virginie Bruen IV', 'Aperiam distinctio sit dolorem asperiores earum veritatis asperiores. Asperiores pariatur quo omnis nulla et voluptate. Quae exercitationem reiciendis repellendus et. Voluptates libero tempora est.', 60698, 40, 'drink', 'https://via.placeholder.com/640x480.png/0022aa?text=est', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(8, 'Anabelle Kilback IV', 'Et natus voluptatum ullam mollitia consequatur. Aperiam et eum et suscipit tempora consequatur quas. Incidunt libero doloremque nisi velit eum.', 16141, 58, 'snack', 'https://via.placeholder.com/640x480.png/00dd77?text=quia', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(9, 'Lea Dicki', 'Praesentium eligendi odio laudantium sunt et quae. Distinctio nisi tempore reiciendis est similique unde. Corrupti quia rerum qui.', 55660, 46, 'drink', 'https://via.placeholder.com/640x480.png/006622?text=impedit', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(10, 'Edwina Stiedemann', 'Perferendis voluptate molestiae aut eveniet repudiandae iure libero. Expedita quis accusantium enim quos. Vel tenetur quos magnam odio.', 13241, 49, 'snack', 'https://via.placeholder.com/640x480.png/005577?text=et', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(11, 'Dr. Maiya Eichmann IV', 'Odio ex non quae aut eaque quia accusamus rerum. Quis quae fugit qui. Impedit consequatur soluta quos laudantium voluptates. Suscipit at et sed incidunt architecto doloremque ratione.', 83377, 45, 'drink', 'https://via.placeholder.com/640x480.png/00aabb?text=doloribus', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(12, 'Dr. Lee Wisozk III', 'Et sed harum occaecati quaerat. Consequatur dolorem exercitationem dolorum atque omnis provident rerum possimus. Voluptas repellat assumenda ad at quos ducimus officia.', 39575, 15, 'food', 'https://via.placeholder.com/640x480.png/0066bb?text=adipisci', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(13, 'Rashad Douglas', 'Nam maxime sed quibusdam atque. Perspiciatis cupiditate expedita sit voluptatem. Porro nisi sint magnam adipisci consequatur ut.', 54079, 72, 'drink', 'https://via.placeholder.com/640x480.png/0066cc?text=enim', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(14, 'Reuben Ankunding', 'Eos tempora repudiandae ex quaerat dolorum reiciendis aliquid. Error a voluptatibus optio aut est harum quidem.', 39592, 84, 'food', 'https://via.placeholder.com/640x480.png/002255?text=et', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(15, 'Ernestine Hudson', 'Nesciunt veniam pariatur nam illo aut soluta id. Rem et ea aut nemo possimus sed reiciendis. Et cumque repellendus et veniam. Autem omnis beatae molestias quidem dolore aliquid.', 12162, 80, 'snack', 'https://via.placeholder.com/640x480.png/007799?text=quo', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(16, 'Prince Morar', 'Omnis id accusamus ratione voluptatibus fuga. Nihil eos beatae corrupti sapiente. Ut dicta hic sequi nihil sit magni labore.', 93235, 93, 'snack', 'https://via.placeholder.com/640x480.png/0066aa?text=eum', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(17, 'Dr. Esteban Roberts', 'Quia sed quas eveniet quia et. Quia enim unde qui reprehenderit blanditiis nemo. Ea debitis quia sed voluptatibus minima quo consectetur voluptatem. Iste saepe fuga aut qui ea quia aut.', 62016, 93, 'snack', 'https://via.placeholder.com/640x480.png/00bb77?text=voluptas', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(18, 'Mr. Bobby Harris', 'Quia cupiditate facere unde cum labore. Ratione soluta dolores omnis optio nostrum. Nemo ad eum consequuntur deserunt dolore. Facere officiis tempora vel error harum dolor quo.', 73713, 69, 'food', 'https://via.placeholder.com/640x480.png/007733?text=architecto', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(19, 'Mrs. Hosea Kautzer', 'At velit esse expedita culpa consequatur tempora cupiditate est. Sit asperiores quidem enim reiciendis. Ratione et nostrum maxime minima.', 66485, 5, 'food', 'https://via.placeholder.com/640x480.png/00ee11?text=libero', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(20, 'Dr. Emma Nolan', 'Assumenda quisquam suscipit rem et magnam velit. Quia veniam quisquam odit odit. Distinctio odit soluta quo quia ratione ut molestiae tempora.', 63982, 3, 'food', 'https://via.placeholder.com/640x480.png/00bb88?text=suscipit', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(21, 'Dr. Alan Cremin IV', 'Sit porro quis nemo eveniet quia hic. Itaque molestiae rerum quis saepe exercitationem. Ut ea velit a ex.', 81471, 67, 'food', 'https://via.placeholder.com/640x480.png/00bb44?text=eius', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(22, 'Brett Bashirian', 'Unde aperiam id in quae ea illo. Molestiae pariatur odit autem excepturi assumenda dolor dolores ratione. Consequatur rerum minima eius itaque.', 12833, 31, 'snack', 'https://via.placeholder.com/640x480.png/00ff22?text=similique', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(23, 'Dr. Beaulah Kulas', 'Vero assumenda eos velit. Ullam occaecati doloribus facere architecto illum voluptatem architecto voluptas. Culpa excepturi cumque accusamus animi.', 62211, 5, 'food', 'https://via.placeholder.com/640x480.png/00bb11?text=deleniti', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(24, 'Jaron O\'Hara', 'Quae voluptatem quas quis incidunt quisquam. Sapiente autem earum fugiat. Nam rem non magnam quis et nam.', 41049, 91, 'food', 'https://via.placeholder.com/640x480.png/005533?text=libero', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(25, 'Jaquelin Little Jr.', 'Neque voluptatem occaecati totam reiciendis consectetur qui vel. Inventore recusandae voluptas sequi eum porro eos deleniti at. Repellendus aut maxime sit. Velit nostrum et officiis sapiente.', 60402, 33, 'food', 'https://via.placeholder.com/640x480.png/00ee22?text=ab', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(26, 'Dr. Kolby Ankunding', 'Voluptates dolores sint autem laudantium. Iure rerum et autem nesciunt tempora quo.', 98008, 56, 'snack', 'https://via.placeholder.com/640x480.png/006622?text=ab', '2026-06-07 01:35:47', '2026-06-07 01:35:47', 0, NULL),
(27, 'Dr. Turner Price', 'Modi sunt reprehenderit perferendis a quibusdam asperiores. Modi suscipit pariatur ut et quia et. Ducimus autem temporibus repellat et perspiciatis atque aperiam. Necessitatibus sit voluptatem qui.', 63083, 79, 'snack', 'https://via.placeholder.com/640x480.png/00dd55?text=ut', '2026-06-07 01:35:47', '2026-06-07 07:50:57', 0, NULL),
(28, 'Dr. Torey Daniel', 'Est neque occaecati laudantium magnam harum. Rerum omnis architecto quasi modi aut accusamus. Quam atque enim consequatur et explicabo eligendi.', 39705, 90, 'drink', 'https://via.placeholder.com/640x480.png/00aaee?text=inventore', '2026-06-07 01:35:47', '2026-06-07 07:35:19', 0, NULL),
(29, 'Hudson Brakus III', 'Molestiae rerum sed doloremque et dolores repellat vero. Voluptas at itaque aut eveniet iusto. Molestias qui commodi et dolor.', 71558, 51, 'drink', 'https://via.placeholder.com/640x480.png/0011cc?text=fuga', '2026-06-07 01:35:47', '2026-06-07 07:50:57', 0, NULL),
(30, 'Delpha Zieme PhD', 'Ducimus soluta quibusdam et. Possimus voluptatibus nihil suscipit velit. Eum non eos illum doloribus qui.', 45464, 46, 'snack', 'https://via.placeholder.com/640x480.png/006633?text=nemo', '2026-06-07 01:35:47', '2026-06-07 07:50:57', 0, NULL);

INSERT INTO `cash_sessions` (`id`, `user_id`, `shift_label`, `opening_float`, `opening_note`, `opened_at`, `cash_in`, `cash_out`, `physical_count`, `expected_cash`, `variance`, `closing_note`, `closed_at`, `created_at`, `updated_at`) VALUES
(1, 3, 'Pagi', 500000, NULL, '2026-06-07 01:35:50', 0, 0, 500000, 500000, 0, '[Force-closed oleh Code with Bahri]', '2026-06-07 01:35:50', '2026-06-07 01:35:50', '2026-06-07 01:35:50'),
(2, 1, 'Siang', 300000, NULL, '2026-06-07 01:35:50', 0, 0, 1327850, 300000, 1027850, NULL, '2026-06-07 07:41:19', '2026-06-07 01:35:50', '2026-06-07 07:41:19'),
(3, 1, 'Siang', 400000, NULL, '2026-06-07 07:50:43', 0, 0, 580105, 400000, 180105, NULL, '2026-06-07 07:57:28', '2026-06-07 07:50:43', '2026-06-07 07:57:28');

INSERT INTO `orders` (`id`, `order_number`, `client_uuid`, `transaction_time`, `total_price`, `total_item`, `kasir_id`, `cash_session_id`, `promo_id`, `payment_method`, `status`, `subtotal`, `discount`, `discount_amount`, `tax`, `amount_paid`, `change_amount`, `customer_name`, `notes`, `refunded_at`, `refund_reason`, `refund_note`, `refund_amount`, `refunded_by_user_id`, `created_at`, `updated_at`) VALUES
(1, 'INV-20260607-0001', '80130b9f-9584-4604-9975-d4d04cc75cac', '2026-06-07 14:20:38', 205576, 4, 1, 2, NULL, 'Tunai', 'paid', 205576.00, 0.00, 0, 0.00, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, 0.00, NULL, '2026-06-07 07:20:41', '2026-06-07 07:20:41'),
(2, 'INV-20260607-0002', '7ea0040a-be52-4d2b-a258-9ba358326040', '2026-06-07 14:23:42', 269282, 4, 1, 2, NULL, 'Tunai', 'paid', 269282.00, 0.00, 0, 0.00, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, 0.00, NULL, '2026-06-07 07:23:44', '2026-06-07 07:23:44'),
(3, 'INV-20260607-0003', '06aa23b9-1aef-4a81-9a6f-dac2a1ab6450', '2026-06-07 14:26:17', 142493, 3, 1, 2, NULL, 'Tunai', 'paid', 142493.00, 0.00, 0, 0.00, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, 0.00, NULL, '2026-06-07 07:26:20', '2026-06-07 07:26:20'),
(4, 'INV-20260607-0004', 'fee194b1-533e-4e49-9a2e-ca3af6f5a51a', '2026-06-07 14:29:36', 205576, 4, 1, 2, NULL, 'Tunai', 'paid', 205576.00, 0.00, 0, 0.00, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, 0.00, NULL, '2026-06-07 07:29:39', '2026-06-07 07:29:39'),
(5, 'INV-20260607-0005', 'dede17bd-5755-4602-b303-7c9dc10c6831', '2026-06-07 14:31:14', 90928, 2, 1, 2, NULL, 'Tunai', 'paid', 90928.00, 0.00, 0, 0.00, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, 0.00, NULL, '2026-06-07 07:31:16', '2026-06-07 07:31:16'),
(6, 'INV-20260607-0006', 'e1c405cd-f855-422e-b773-167ea325528c', '2026-06-07 14:35:16', 113995, 3, 1, 2, NULL, 'Tunai', 'paid', 113995.00, 0.00, 0, 0.00, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, 0.00, NULL, '2026-06-07 07:35:19', '2026-06-07 07:35:19'),
(7, 'INV-20260607-0007', '24b8584e-5453-4246-9835-03f445dfcf01', '2026-06-07 14:50:55', 180105, 3, 1, 3, NULL, 'Tunai', 'paid', 180105.00, 0.00, 0, 0.00, 0.00, 0.00, NULL, NULL, NULL, NULL, NULL, 0.00, NULL, '2026-06-07 07:50:57', '2026-06-07 07:50:57');

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `quantity`, `total_price`, `created_at`, `updated_at`) VALUES
(1, 1, 28, 2, 39705, '2026-06-07 07:20:41', '2026-06-07 07:20:41'),
(2, 1, 27, 2, 63083, '2026-06-07 07:20:41', '2026-06-07 07:20:41'),
(3, 2, 29, 2, 71558, '2026-06-07 07:23:44', '2026-06-07 07:23:44'),
(4, 2, 27, 2, 63083, '2026-06-07 07:23:44', '2026-06-07 07:23:44'),
(5, 3, 28, 2, 39705, '2026-06-07 07:26:20', '2026-06-07 07:26:20'),
(6, 3, 27, 1, 63083, '2026-06-07 07:26:20', '2026-06-07 07:26:20'),
(7, 4, 28, 2, 39705, '2026-06-07 07:29:39', '2026-06-07 07:29:39'),
(8, 4, 27, 2, 63083, '2026-06-07 07:29:39', '2026-06-07 07:29:39'),
(9, 5, 30, 2, 45464, '2026-06-07 07:31:16', '2026-06-07 07:31:16'),
(10, 6, 28, 2, 39705, '2026-06-07 07:35:19', '2026-06-07 07:35:19'),
(11, 6, 27, 1, 63083, '2026-06-07 07:35:19', '2026-06-07 07:35:19'),
(12, 7, 29, 1, 71558, '2026-06-07 07:50:57', '2026-06-07 07:50:57'),
(13, 7, 30, 1, 45464, '2026-06-07 07:50:57', '2026-06-07 07:50:57'),
(14, 7, 27, 1, 63083, '2026-06-07 07:50:57', '2026-06-07 07:50:57');

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 3, 'mobile', '132941829426598b035a0c0b51c45fd066165946f3bbf9948d8358ec0e5d2e25', '[\"*\"]', '2026-06-07 01:35:50', NULL, '2026-06-07 01:35:50', '2026-06-07 01:35:50'),
(2, 'App\\Models\\User', 1, 'mobile', '8af9705bc29ac69112ef8824725af81197e6d8639e9bc818d1d27020e1860efe', '[\"*\"]', '2026-06-07 01:35:50', NULL, '2026-06-07 01:35:50', '2026-06-07 01:35:50');

SET FOREIGN_KEY_CHECKS = 1;
