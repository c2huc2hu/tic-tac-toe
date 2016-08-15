# tic tac toe player

PLAYER_COLORS = ['blue', 'red']

# initialize the board
class Board
	constructor: (@element, @infoElem, @undoElem) ->
		@element.onclick = (e) => @onClick(e)
		@undoElem.onclick = (e) => @undo()
		@recreate([])

		for i in [0...9]
			node = document.createElement 'li'
			node.setAttribute 'id', "sq#{i}"
			node.setAttribute 'class', 'square'
			node.order = i
			@element.appendChild node

	recreate: (pastMoves) ->
		console.log pastMoves
		@pastMoves = []
		@board = (0 for [0...9])
		@curPlayer = 1
		@curWinner = 0
		for move in pastMoves
			@playAt(move)

	undo: ->
		@pastMoves.pop()
		@recreate(@pastMoves)
		@render()

	checkWin: ->

		# arr: an array of elements
		# filter: a function to filter the array, passed (element, index)
		# returns: checks if all elements that pass the filter are the same. returns the element if they are
		# 			otherwise returns false
		# 			if array is empty, returns undefined
		same = (arr, filter) ->
			first = undefined
			for val, index in arr
				if filter val, index
					first ?= val
					return false if val isnt first
			return first

		# note that we exclude when the 'winner' is empty cells because if (0) doesn't evaluate
		# note the abuse of the assignment operator
		for i in [0..2]
			return winner if winner = same @board, (x, j) -> j % 3 is i  # horizontal
			return winner if winner = same @board, (x, j) -> j // 3 is i # vertical
		return winner if winner = same @board, (x, j) -> j % 3 is j // 3  # diagonals
		return winner if winner = same @board, (x, j) -> j % 3 is 2 - j // 3
		return false

	playAt: (index) ->
		@pastMoves.push index
		@board[index] = @curPlayer
		@curPlayer = @curPlayer % 2 + 1

		@curWinner = @checkWin()

	onClick: (e) ->
		if not @curWinner
			@playAt e.target.order
		@render()

	render: ->
		# who needs jquery anyway
		for val, index in @board
			node = document.getElementById "sq#{index}"
			node.setAttribute "player", val
			node.style.setProperty 'height', "calc(#{100/3}%-2px);"
			node.style.setProperty 'width', "calc(#{100/3}%-2px);"
			node.classList.remove 'prev'

		if @pastMoves.length >= 1
			document.getElementById("sq#{@pastMoves[@pastMoves.length - 1]}").classList.add 'prev'

		@infoElem.textContent = "Player #{@curPlayer}'s turn"
		@infoElem.textContent = "Player #{@curWinner} has won" if @curWinner
		@infoElem.style.setProperty 'color', PLAYER_COLORS[(@curWinner or @curPlayer) - 1]

b = new Board document.getElementById('board'), document.getElementById('info'), document.getElementById('undo')
b.render()