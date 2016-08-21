# tic tac toe player for utek. this is the main script
# Util functions

# Max and min of array
max = (arr) ->
	res = -Infinity
	for i in arr
		res = i if i > res
	return res
min = (arr) ->
	res = Infinity
	for i in arr
		res = i if i < res
	return res

# return the index of the maximum element
maxIndex = (arr) ->
	return if arr is []
	mx = -Infinity
	result = 0
	for elem, index in arr
		result = index if elem > mx
		mx = elem if elem > mx
	return result
minIndex = (arr) ->
	return if arr is []
	mn = Infinity
	result = 0
	for elem, index in arr
		result = index if elem < mn
		mn = elem if elem < mn
	return result

checkWin = (arr) ->
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
		return winner if winner = same arr, (x, j) -> j % 3 is i  # horizontal
		return winner if winner = same arr, (x, j) -> j // 3 is i # vertical
	return winner if winner = same arr, (x, j) -> j % 3 is j // 3  # diagonals
	return winner if winner = same arr, (x, j) -> j % 3 is 2 - j // 3
	return false

minimax = (board, curPlayer, depth) ->
	winner = checkWin(board)
	return 20 - depth if winner is 1
	return -20 + depth if winner is 2
	return 0 if depth is 8
	scores = (undefined for [0..8])
	for elem, index in board
		continue if elem
		newBoard = board[..]
		newBoard[index] = curPlayer
		scores[index] = minimax newBoard, curPlayer % 2 + 1, depth + 1
	return max(scores) if curPlayer is 1
	return min(scores) if curPlayer is 2


# initialize the board
class Board
	constructor: (@element, @infoElem, @undoElem, @resetElem) ->
		@element.onclick = (e) => @onClick(e)
		@undoElem.onclick = (e) => @undo()
		@resetElem.onclick = (e) => @recreate([])
		@recreate([])

		for i in [0...9]
			node = document.createElement 'li'
			node.setAttribute 'id', "sq#{i}"
			node.setAttribute 'class', 'square'
			node.order = i
			@element.appendChild node

	recreate: (pastMoves) ->
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
		checkWin(@board)

	catsGame: ->
		return not @board.some (x) -> x is 0

	playAt: (index) ->
		return if @board[index]
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
			node.setAttribute "suggested", false
			node.style.setProperty 'height', "calc(#{100/3}%-2px);"
			node.style.setProperty 'width', "calc(#{100/3}%-2px);"
			node.classList.remove 'prev'

		if @pastMoves.length >= 1
			document.getElementById("sq#{@pastMoves[@pastMoves.length - 1]}").classList.add 'prev'

		@infoElem.textContent = "Player #{@curPlayer}'s turn"
		@infoElem.textContent = "Player #{@curWinner} has won" if @curWinner
		@infoElem.setAttribute 'player', @curWinner or @curPlayer
		if @catsGame()
			@infoElem.textContent = "Cat's game"
			@infoElem.setAttribute 'player', 0

		document.getElementById("sq#{@suggestMove()}").setAttribute 'suggested', @curPlayer if not @checkWin() and not @catsGame()

	suggestMove: ->
		d = Date.now()
		scores = (undefined for [0..8])
		for elem, index in @board
			continue if elem
			newBoard = @board[..]
			newBoard[index] = @curPlayer
			scores[index] = minimax newBoard, @curPlayer % 2 + 1, @pastMoves.length
		console.log "scores", Date.now() - d
		return maxIndex(scores) if @curPlayer is 1
		return minIndex(scores) if @curPlayer is 2


b = new Board document.getElementById('board'), document.getElementById('info'), document.getElementById('undo'), document.getElementById('reset')
b.render()