function file.Iterate(dir, entrypoint, path, callback, allFiles)
	if not file.IsDir(dir, path) then
		return
	end

	if entrypoint and file.Exists(dir .. entrypoint, path) then
		callback(dir .. entrypoint, dir)

		return
	end

	local files = file.Find(dir .. "*", path)

	for _, filePath in ipairs(files) do
		if allFiles or string.GetExtensionFromFilename(filePath) == "lua" then
			callback(dir .. filePath, dir)
		end
	end
end

function file.IterateRecursive(dir, entrypoint, path, callback, allFiles)
	if not file.IsDir(dir, path) then
		return
	end

	if entrypoint and file.Exists(dir .. entrypoint, path) then
		callback(dir .. entrypoint, dir)

		return
	end

	local files, folders = file.Find(dir .. "*", path)

	for _, filePath in ipairs(files) do
		if allFiles or string.GetExtensionFromFilename(filePath) == "lua" then
			callback(dir .. filePath, dir)
		end
	end

	for _, folderPath in ipairs(folders) do
		file.IterateRecursive(dir .. folderPath .. "/", entrypoint, path, callback, recursive, allFiles)
	end
end

function file.WriteSafe(path, contents)
	file.CreateDir(string.GetPathFromFilename(path))
	file.Write(path, contents)
end

function file.AppendSafe(path, contents)
	file.CreateDir(string.GetPathFromFilename(path))
	file.Append(path, contents)
end

function file.OpenSafe(path, mode)
	file.CreateDir(string.GetPathFromFilename(path))
	return file.Open(path, mode, "DATA")
end
