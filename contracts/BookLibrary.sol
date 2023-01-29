// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

/**
@dev Import the Ownable contract.
*/
import "./Ownable.sol";

/**
	@title BookLibrary
	@notice This contract implements a library where books can be added, borrowed, and returned. It also allows to view the whole list of books and the complete
	list of borrowers for  a given  book
	@dev  It inherits from the Ownable contract to ensure that only the owner can add books.
	@author Baltasar Romero
*/
contract BookLibrary is Ownable {
	///@dev Mapping of books in the library. The key is the book ID and the value is the book information.
	mapping(uint => Book) public books;
	///@dev Mapping of current book borrowers. The first key is the book ID, the second key is the borrower address, and the value is a boolean indicating whether the book is currently borrowed
	///	by that address.
	mapping (uint => mapping(address => bool)) public currentBookBorrowers;
	///@dev Mapping of historical book borrowers. The first key is the book ID, the second key is the borrower address, and the value is a boolean indicating whether the book is currently borrowed
	///	by that address.
	mapping (uint => mapping(address => bool)) public historicalBookBorrowers;
	/// @dev Counter to keep track of the number of books in the library.
	uint public bookCount;

	///	@dev Struct that defines the book information.
	/// @dev Title of the book.
	/// @dev Total number of copies of the book.
	/// @dev Number of borrowed copies of the book.
	/// @dev Array of addresses of the borrowers.
	struct Book {
		string title;
		uint copies;
		uint borrowedCopies;
		address[] borrowers;
	}

	/// @dev Function to add a book to the library. Only the owner can add a book.
	/// @param _title Title of the book.
	/// @param _copies Total number of copies of the book.
	function addBook(string memory _title, uint _copies) public onlyOwner { 
		books[bookCount] =  Book({
			title: _title,
			copies: _copies,
			borrowedCopies: 0,
			borrowers: new address[](0)
		});
		bookCount++;
	}

	/// @dev Function to view the books in the library.
	/// @return Array of book titles and array of available copies of each book.
	function viewBooks() public view returns (string[] memory, uint[] memory) {
		string[] memory titles = new string[](bookCount);
		uint[] memory copies = new uint[](bookCount);
		for (uint i = 0; i < bookCount; i++) {
			titles[i] = books[i].title;
			copies[i] = books[i].copies - books[i].borrowedCopies;
		}
		return (titles, copies);
	}
	
	///	@dev Allows a user to borrow a book from the library.
	///	@param _bookId The ID of the book to be borrowed.
	///	@notice returns the error "The requested book does not exist." If the book ID is not valid.
	///	@notice returns the error "There are no more available copies of this book." If all copies of the book have been borrowed.
	///	@notice returns the error "You have already borrowed this book." If the user has already borrowed this book.
	function borrowBook(uint _bookId) public {
		require(_bookId < bookCount, "The requested book does not exist.");
		Book storage book = books[_bookId];
		require(book.borrowedCopies < book.copies, "There are no more available copies of this book.");
		require(!currentBookBorrowers[_bookId][msg.sender], "You have already borrowed this book.");
		currentBookBorrowers[_bookId][msg.sender] = true;
		book.borrowedCopies++;
		
		// Only add to the history of borrowers if it's the first time that is borrowing a given  book
		if (!historicalBookBorrowers[_bookId][msg.sender] ) {
			historicalBookBorrowers[_bookId][msg.sender] = true;
			book.borrowers.push(msg.sender);
		}	
	}

	/// @dev Allows a user to return a book they have borrowed from the library.
	/// @param _bookId The ID of the book to be returned.
	/// @notice retuurns the error:  "The requested book does not exist." If the book ID is not valid.
	/// @notice retuurns the error: "You are not borrowing this book." If the user is not currently borrowing the book.
	function returnBook(uint _bookId) public {
		require(_bookId < bookCount, "The requested book does not exist.");
		Book storage book = books[_bookId];
		require(currentBookBorrowers[_bookId][msg.sender], "You have not borrowed this book.");
		currentBookBorrowers[_bookId][msg.sender] = false;
		book.borrowedCopies--;
	}

	/// @dev Allows the user to view a list of borrowers for a specific book.
	/// @param _bookId The ID of the book to view the borrowers of.
	/// @notice returns An array of addresses representing the borrowers of the book.
	/// @notice returns the error: "The requested book does not exist." If the book ID is not valid.
	function viewBorrowers(uint _bookId) public view returns (address[] memory) {
		require(_bookId < bookCount, "The requested book does not exist.");
		return books[_bookId].borrowers;
	}
}