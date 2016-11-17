context("hash")

test_that("serialize, dropping R version", {
  s1 <- serialize_object(NULL, TRUE, FALSE)
  s2 <- serialize_object(NULL, TRUE, TRUE)
  expect_false(identical(s1, s2))
  i <- 7:10
  expect_identical(s1[-i], s2[-i])
  expect_identical(s2[i], STORR_R_VERSION_BE)

  expect_identical(unserialize(s1), unserialize(s2))
})

test_that("reverse engineering", {
  skip_on_cran()
  ## With xdr = TRUE (the default)
  ##
  ##                           ma mi pa    ma mi pa
  ##  [1] 58 0a 00 00 00 02 00 03 02 03 00 02 03 00 -- 3.2.3
  ##  [1] 58 0a 00 00 00 02 00 03 03 00 00 02 03 00 -- 3.3.1
  ##      ^^^^^ ^^^^^^^^^^^ ^^^^^^^^^^^ ^^^^^^^^^^^
  ##      1.    2.          3.          4.
  ##
  ## with xdr = FALSE
  ##
  ##                        pa mi ma    pa mi ma
  ##  [1] 42 0a 02 00 00 00 03 02 03 00 00 03 02 00 -- 3.2.3
  ##  [1] 42 0a 02 00 00 00 00 03 03 00 00 03 02 00 -- 3.3.1
  ##      ^^^^^ ^^^^^^^^^^^ ^^^^^^^^^^^ ^^^^^^^^^^^
  ##      1.   2.           3.          4.

  ## 1. serialisation type
  ## 2. version of the serialisation (must be 2 at present)
  ## 3. version of R written by
  ## 4. minimum version of r to read the file

  s1 <- serialize_object(NULL, TRUE,  FALSE)
  s2 <- serialize_object(NULL, FALSE, FALSE)

  s1[6] <- as.raw(3L)
  expect_error(unserialize(s1), "cannot read workspace version 3")
  s1[7:10] <- as.raw(c(0L, 6L, 5L, 4L)) # version 6.5.4
  expect_error(unserialize(s1), "6.5.4", fixed = TRUE)

  s2[3] <- as.raw(3L)
  expect_error(unserialize(s2), "cannot read workspace version 3")
  s2[10:7] <- as.raw(c(0L, 6L, 5L, 4L)) # version 6.5.4
  expect_error(unserialize(s2), "6.5.4", fixed = TRUE)
})