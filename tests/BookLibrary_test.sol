// SPDX-License-Identifier: GPL-3.0
        
pragma solidity ^0.8.0;

import "remix_tests.sol"; 
import "remix_accounts.sol";
import "../contracts/BookLibrary.sol";

/// @dev Tests for the BookLibrary contract
contract BookLibraryTests {
    /// Define variables referring to different accounts
    address public acc0;
    address public acc1;
    address public acc2;

    BookLibrary public bookLibrary;
    address public owner;
    
    /// Initiate accounts variable
    function beforeAll() public {
        acc0 = TestsAccounts.getAccount(0); 
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
    }

    /// #sender: account-0 (deployer will always be 0)
    function beforeEach() public {
        bookLibrary = new BookLibrary();
        owner = address(bookLibrary.owner());
    }

    // @dev Test to add a book to the library. Check if the book is added successfully.
    function testAddBook() public {
        bookLibrary.addBook("One Hundred Years of Solitude", 5);
        string[] memory titles;
        uint[] memory copies;
        (titles, copies) = bookLibrary.viewBooks();
        Assert.equal(titles[0], "One Hundred Years of Solitude", "The title of the book is not correct");
        Assert.equal(copies[0], 5, "The number of copies is not correct");
    }

    /// #sender: account-1 (sender is account at index '1')
    function addBookWithAccount1(string memory _title, uint _id) private {
        bookLibrary.addBook(_title, _id);
    }


    /// @dev Test to view the books in the library. Check if the book list is correct.
    function testViewBooks() public {
        bookLibrary.addBook("One Hundred Years of Solitude", 5);
        bookLibrary.addBook("1984", 4);
        string[] memory titles;
        uint[] memory copies;
        (titles, copies) = bookLibrary.viewBooks();
        Assert.equal(titles[0], "One Hundred Years of Solitude", "The first book title is not correct");
        Assert.equal(titles[1], "1984", "The second book title is not correct");
        Assert.equal(copies[0], 5, "The number of copies of the first book is not correct");
        Assert.equal(copies[1], 4, "The number of copies of the second book is not correct");
    }
    
    // @dev Test to borrow a book from the library. Check if the book is borrowed successfully.
    function testBorrowBook() public {
        bookLibrary.addBook("One Hundred Years of Solitude", 5);
        uint bookId = 0;
        bookLibrary.borrowBook(bookId);   
        bool isBorrowed  = bookLibrary.currentBookBorrowers(bookId, bookLibrary.owner());
        Assert.equal(isBorrowed, true, "The book is not borrowed");
    }

    // @dev Test to borrow a book from the library. Check if the book is borrowed successfully.
    function testDoubleBorrowingShouldFail() public {
        bookLibrary.addBook("One Hundred Years of Solitude", 5);
        uint bookId = 0;
        bookLibrary.borrowBook(bookId);   
        try bookLibrary.borrowBook(bookId) {
            Assert.ok(false, "method execution should fail");
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, "You have already borrowed this book.", "failed with unexpected reason");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'failed unexpected');
        }
    }
}
    