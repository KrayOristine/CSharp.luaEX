-- Generated by CSharp.lua Compiler 1.0.0.0
local System = System;
local Linq = System.Linq.Enumerable;
local MicrosoftCodeAnalysis = Microsoft.CodeAnalysis;
local MicrosoftCodeAnalysisCSharp = Microsoft.CodeAnalysis.CSharp;
local SystemIO = System.IO;
local SystemLinq = System.Linq;
local SystemRuntimeInteropServices = System.Runtime.InteropServices;
local CSharpLua;
System.usingDeclare(function (global) 
    CSharpLua = global.CSharpLua;
end);
System.namespace("CSharpLua", function (namespace) 
    namespace.class("Worker", function (namespace) 
        local SystemDlls, getMetas, getLibs, Do, Compiler, __staticCtor__, __ctor__;
        getMetas = function (this) 
            local metas = System.List(System.String)();
            metas:Add(CSharpLua.Utility.GetCurrentDirectory("~/System.xml" --[[Worker.kSystemMeta]]));
            metas:AddRange(this.metas_);
            return metas;
        end;
        getLibs = function (this) 
            local runtimeDir = SystemRuntimeInteropServices.RuntimeEnvironment.GetRuntimeDirectory();
            local libs = System.List(System.String)();
            libs:AddRange(Linq.Select(SystemDlls, function (i) return SystemIO.Path.Combine(runtimeDir, i); end, System.String));
            for _, lib in System.each(this.libs_) do
                local default;
                if lib:EndsWith(".dll" --[[Worker.kDllSuffix]]) then
                    default = lib;
                else
                    default = (lib or "") .. ".dll" --[[Worker.kDllSuffix]];
                end
                local path = default;
                if not System.File.Exists(path) then
                    local file = SystemIO.Path.Combine(runtimeDir, SystemIO.Path.GetFileName(path));
                    if not System.File.Exists(file) then
                        System.throw(CSharpLua.CmdArgumentException(("lib '{0}' is not found"):Format(path)));
                    end
                    path = file;
                end
                libs:Add(path);
            end
            return libs;
        end;
        Do = function (this) 
            Compiler(this);
        end;
        Compiler = function (this) 
            local parseOptions = MicrosoftCodeAnalysisCSharp.CSharpParseOptions(6, 1, 0, this.defines_);
            local files = SystemIO.Directory.EnumerateFiles(this.folder_, "*.cs", 1 --[[SearchOption.AllDirectories]]);
            local syntaxTrees = Linq.Select(files, function (file) return MicrosoftCodeAnalysisCSharp.CSharpSyntaxTree.ParseText(System.File.ReadAllText(file), parseOptions, file, nil, nil); end, MicrosoftCodeAnalysis.SyntaxTree);
            local references = Linq.Select(getLibs(this), function (i) return MicrosoftCodeAnalysis.MetadataReference.CreateFromFile(i, nil, nil); end, MicrosoftCodeAnalysis.PortableExecutableReference);
            local compilation = MicrosoftCodeAnalysisCSharp.CSharpCompilation.Create("_", syntaxTrees, references, MicrosoftCodeAnalysisCSharp.CSharpCompilationOptions(2 --[[OutputKind.DynamicallyLinkedLibrary]], false, nil, nil, nil, nil, 0, false, false, nil, nil, nil, nil, 0, 0, 4, nil, true, false, nil, nil, nil, nil, nil, false));
            System.using(SystemIO.MemoryStream(), function (ms) 
                local result = compilation:Emit(ms, nil, nil, nil, nil, nil, nil, nil);
                if not result:getSuccess() then
                    local errors = SystemLinq.ImmutableArrayExtensions.Where(result:getDiagnostics(), function (i) return i:getSeverity() == 3 --[[DiagnosticSeverity.Error]]; end, MicrosoftCodeAnalysis.Diagnostic);
                    local message = System.String.Join("\n", errors, MicrosoftCodeAnalysis.Diagnostic);
                    System.throw(CSharpLua.CompilationErrorException(message));
                end
            end);

            local generator = CSharpLua.LuaSyntaxGenerator:new(1, getMetas(this), compilation);
            generator:Generate(this.folder_, this.output_);
        end;
        __staticCtor__ = function (this) 
            SystemDlls = System.Array(System.String)("mscorlib.dll", "System.dll", "System.Core.dll", "Microsoft.CSharp.dll");
        end;
        __ctor__ = function (this, folder, output, lib, meta, defines) 
            this.folder_ = folder;
            this.output_ = output;
            this.libs_ = CSharpLua.Utility.Split(lib, true);
            this.metas_ = CSharpLua.Utility.Split(meta, true);
            this.defines_ = CSharpLua.Utility.Split(defines, false);
        end;
        return {
            Do = Do, 
            __staticCtor__ = __staticCtor__, 
            __ctor__ = __ctor__
        };
    end);
end);
